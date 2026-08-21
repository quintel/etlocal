# frozen_string_literal: true

require 'csv'
require 'amalgamator/combiner'

module Amalgamator
  # Combines many target regions in one run, for example all provinces or all RES regions at once.
  #
  # The batch is described by a mapping CSV in which every row represents one source region
  # (e.g. a municipality) and names the target region that source belongs to (e.g. a province).
  # Rows are grouped by target geo-id and every group is handed to the Amalgamator::Combiner,
  # which writes one migration per target region.
  #
  # Columns are addressed either by (part of) their header or by their 1-based position, so the
  # same mapping file can be reused for different aggregations by pointing at a different column.
  #
  # Example usage:
  #
  #   Amalgamator::BatchCombiner.new(
  #     mapping_file: 'CBS Gebieden in Nederland 2023 - ETM version.csv',
  #     source_geo_id_column: 'gemeenten|Code',
  #     target_geo_id_column: 'Provincies|Code',
  #     source_data_year: '2023',
  #     target_parent_name: 'nl2023',
  #     migration_slug: 'heat_pump_update'
  #   ).perform
  #
  class BatchCombiner
    # Seconds to wait between two checks for a free migration version.
    VERSION_POLL_INTERVAL = 0.2

    # One target region and the source regions that make it up.
    Target = Struct.new(:geo_id, :name, :parent_name, :source_geo_ids)

    # Arguments:
    #   mapping_file: Path to the CSV that maps source regions onto target regions
    #   source_geo_id_column: Header (or 1-based index) of the column with the source geo-ids
    #   target_geo_id_column: Header (or 1-based index) of the column with the target geo-ids
    #   source_data_year: The year over which new data should be calculated
    #   target_name_column (optional): Header (or index) of the column with the target names.
    #       If omitted the names are looked up through the existing target datasets.
    #   target_parent_name (optional): Parent of every target dataset, e.g. 'nl2023'.
    #       If omitted the parent of each existing target dataset is used.
    #   migration_slug (optional): Slug of the migrations to generate, e.g. 'heat_pump_update'.
    #       If omitted the source_data_year is used.
    #   only (optional): Array of target geo-ids to restrict the batch to
    #   except (optional): Array of target geo-ids to skip
    #   dry_run (optional): Report what would be combined without writing any migration
    #   force (optional): Replace migrations that were generated for the same target and slug before
    #   allow_missing_sources (optional): Continue when a source geo-id has no dataset. Beware:
    #       missing sources are silently left out of the sum.
    def initialize(
      mapping_file:, source_geo_id_column:, target_geo_id_column:, source_data_year:,
      target_name_column: nil, target_parent_name: nil, migration_slug: nil,
      only: nil, except: nil, dry_run: false, force: false, allow_missing_sources: false
    )
      @mapping_file = mapping_file
      @source_geo_id_column = source_geo_id_column
      @target_geo_id_column = target_geo_id_column
      @source_data_year = source_data_year
      @target_name_column = target_name_column
      @target_parent_name = target_parent_name
      @migration_slug = migration_slug
      @only = Array(only).map { |id| id.to_s.strip }.compact_blank
      @except = Array(except).map { |id| id.to_s.strip }.compact_blank
      @dry_run = dry_run
      @force = force
      @allow_missing_sources = allow_missing_sources

      @used_versions = []

      validate_input
    end

    # Combines every target region in the mapping file and returns the filenames of the
    # generated migrations. Returns an empty array for a dry run.
    def perform
      targets = self.targets

      validate_targets(targets)
      report_plan(targets)

      return [] if @dry_run

      migration_filenames = targets.map { |target| combine(target) }

      report_result(migration_filenames)

      migration_filenames
    end

    # The target regions found in the mapping file, after applying the 'only'/'except' filters.
    def targets
      @targets ||= build_targets(grouped_source_geo_ids)
    end

    private

    def combine(target)
      puts "\n[#{target.geo_id}] #{target.name}: " \
           "combining #{target.source_geo_ids.length} datasets..."

      combiner = Amalgamator::Combiner.new(
        target_dataset_geo_id: target.geo_id,
        source_data_year: @source_data_year,
        source_dataset_geo_ids: target.source_geo_ids,
        target_area_name: target.name,
        target_parent_name: target.parent_name,
        migration_slug: migration_slug
      )

      combiner.result

      # Migration versions have a one-second resolution, so make sure the previous export and
      # any pre-existing migration did not already claim the version this export would get.
      await_free_migration_version

      migration_filename = combiner.export_data
      @used_versions << migration_filename[0...14]

      puts "[#{target.geo_id}] Exported db/migrate/#{migration_filename}"

      migration_filename
    end

    # Reads the mapping file and groups the source geo-ids by target geo-id. Returns a hash of
    # target geo-ids pointing at the target name found in the file (if any) and its sources.
    def grouped_source_geo_ids
      rows = CSV.read(@mapping_file, encoding: 'bom|utf-8')
      headers = rows.shift

      source_index = column_index(headers, @source_geo_id_column, 'source_geo_id_column')
      target_index = column_index(headers, @target_geo_id_column, 'target_geo_id_column')
      name_index = if @target_name_column.present?
        column_index(headers, @target_name_column, 'target_name_column')
      end

      rows.each_with_object({}) do |row, groups|
        target_geo_id = row[target_index].to_s.strip
        source_geo_id = row[source_index].to_s.strip

        next if target_geo_id.blank? || source_geo_id.blank?

        group = groups[target_geo_id] ||= {
          name: name_index ? row[name_index].to_s.strip : nil,
          source_geo_ids: []
        }

        unless group[:source_geo_ids].include?(source_geo_id)
          group[:source_geo_ids] << source_geo_id
        end
      end
    end

    # Targets are sorted by geo-id so that the generated migrations follow a predictable order.
    def build_targets(groups)
      groups.sort.filter_map do |geo_id, group|
        next if @only.present? && @only.exclude?(geo_id)
        next if @except.present? && @except.include?(geo_id)

        dataset = Dataset.find_by(geo_id: geo_id)
        name = group[:name].presence || dataset&.name

        if name.blank?
          argument_error(
            "No name found for target '#{geo_id}'. Either add a target_name_column to the " \
            'mapping file arguments, or create the dataset first'
          )
        end

        Target.new(
          geo_id: geo_id,
          name: name,
          parent_name: @target_parent_name.presence || dataset&.parent,
          source_geo_ids: group[:source_geo_ids]
        )
      end
    end

    # Resolves a column by (part of) its header, or by its 1-based position in the file.
    def column_index(headers, column, argument_name)
      return column.to_i - 1 if column.to_s.match?(/\A\d+\z/)

      index = headers.index { |header| header.to_s.downcase.include?(column.to_s.downcase) }

      if index.nil?
        argument_error(
          "No column matching '#{column}' was found for #{argument_name}. " \
          "The mapping file contains: #{headers.join(', ')}"
        )
      end

      index
    end

    # Defaults to the source data year, just like Amalgamator::Base does for a single combination.
    # A per-target slug is not needed to keep the migrations apart: the exporter already prefixes
    # every migration name with the geo-id and the name of the target region.
    def migration_slug
      (@migration_slug.presence || @source_data_year).to_s.downcase
    end

    # Mirrors the migration name that Amalgamator::DatasetExporter will derive for this target.
    def migration_name_for(target)
      [target.geo_id, target.name, migration_slug]
        .join('_')
        .gsub(/[^\w]/, '_')
        .downcase
    end

    def existing_migrations_for(target)
      Rails.root.glob("db/migrate/*_#{migration_name_for(target)}.rb")
    end

    def validate_input
      empty_args = {
        mapping_file: @mapping_file,
        source_geo_id_column: @source_geo_id_column,
        target_geo_id_column: @target_geo_id_column,
        source_data_year: @source_data_year
      }.select { |_arg, value| value.blank? }

      if empty_args.present?
        argument_error("The following mandatory arguments were omitted: #{empty_args.keys.join(', ')}")
      end

      unless File.exist?(@mapping_file)
        argument_error("The mapping file '#{@mapping_file}' does not exist")
      end
    end

    def validate_targets(targets)
      argument_error('No target regions were found in the mapping file') if targets.empty?

      validate_source_datasets(targets)
      validate_migrations(targets)
    end

    # Amalgamator::Combiner silently ignores geo-ids without a dataset, which would quietly
    # leave a region out of the sum. Report them before anything is written.
    def validate_source_datasets(targets)
      known_geo_ids = Dataset.where(geo_id: targets.flat_map(&:source_geo_ids)).pluck(:geo_id)

      missing = targets.filter_map do |target|
        unknown = target.source_geo_ids - known_geo_ids
        "#{target.geo_id} (#{target.name}): #{unknown.join(', ')}" if unknown.present?
      end

      return if missing.empty?

      message = "No dataset exists for the following source geo-ids:\n#{missing.join("\n")}"

      if @allow_missing_sources
        warn("Warning: #{message}\nThey are left out of the combined datasets")
      else
        argument_error(message)
      end
    end

    # Rails refuses to migrate when two migrations share a name, so a target that was combined
    # under the same slug before has to be replaced rather than added to.
    def validate_migrations(targets)
      existing = targets
        .index_with { |target| existing_migrations_for(target) }
        .reject { |_target, migrations| migrations.empty? }

      return if existing.empty?

      unless @force
        argument_error(
          "Migrations for the following targets and slug already exist:\n" \
          "#{existing.values.flatten.map { |path| File.basename(path) }.join("\n")}\n" \
          'Remove them, choose another migration_slug, or pass force to replace them'
        )
      end

      return if @dry_run

      existing.each_value do |migrations|
        migrations.each do |path|
          puts "Replacing existing migration #{File.basename(path)}"
          FileUtils.rm_rf(path.to_s.delete_suffix('.rb'))
          File.delete(path)
        end
      end
    end

    # Waits until DateTime.now yields a migration version that is not in use yet.
    def await_free_migration_version
      while claimed_migration_versions.include?(current_migration_version)
        sleep(VERSION_POLL_INTERVAL)
      end
    end

    def current_migration_version
      DateTime.now.strftime('%Y%m%d%H%M%S')
    end

    def claimed_migration_versions
      @claimed_migration_versions ||=
        Rails.root.glob('db/migrate/*.rb').map { |path| File.basename(path)[0...14] }

      @claimed_migration_versions + @used_versions
    end

    def report_plan(targets)
      puts "\nCombining #{targets.length} target regions from #{@mapping_file}:"

      targets.each do |target|
        puts format(
          '  %<geo_id>-8s %<name>-28s %<sources>3d sources -> %<migration>s',
          geo_id: target.geo_id,
          name: target.name,
          sources: target.source_geo_ids.length,
          migration: "#{migration_name_for(target)}.rb"
        )
      end

      puts "\nDry run: no migrations were written." if @dry_run
    end

    def report_result(migration_filenames)
      puts "\nWrote #{migration_filenames.length} migrations to db/migrate:"
      migration_filenames.each { |filename| puts "  #{filename}" }
    end

    def argument_error(msg)
      raise ArgumentError, "#{msg}. Aborting."
    end
  end
end
