# frozen_string_literal: true

# The Amalgamator parent class acts as the interface through which smaller areas can be
# combined into a bigger one, or a dataset can be subtracted from another one. It validates user input, sets defaults
# and then delegates the work to the ValueProcessor and DataExporter that do the actual combining/separating.
# See the 'initialize' method for (expected) arguments.
#
# Example usage:
#
#   # Init the combiner with information on source- and target datasets
#   combiner = DatasetCombiner.new(
#     target_dataset_geo_id: 'PV20',
#     source_data_year: '2019',
#     source_dataset_geo_ids: %w[GM306 GM307 GM308],
#     target_area_name: 'Groningen',                  # Optional
#     target_country_name: 'nl2019',                  # Optional
#     migration_slug: 'update_2019'                   # Optional
#   )
#
#   # Instruct the combiner to combine the datasets into a new one
#   # (lets ValueProcessor do its job, see for details on combining)
#   combiner.combine_datasets
#
#   # Instruct the combiner to export the new dataset to several files
#   # (lets DataExporter do its job, see for details on exporting)
#   migration_filename = combiner.export_data
#

module Amalgamator
  class Base
    # Arguments:
    #   target_dataset_geo_id: Identifier of dataset to combine into or subtract from, e.g.: 'PV20'
    #   source_data_year: The year over which new data should be calculated
    #   source_dataset_geo_ids: Identifiers for areas to be combined (Array) or a single identifier (String) to be subtracted
    #   target_area_name (optional): Name of the target area, e.g.: 'Groningen'
    #   target_country_name (optional): Name of the country of the target dataset, e.g. 'nl2019'
    #   migration_slug (optional): Short description of migration in lowercase and underscores, e.g.: 'update_2023'
    def initialize(
      target_dataset_geo_id:, source_data_year:, source_dataset_geo_ids:,
      target_area_name: nil, target_country_name: nil, migration_slug: nil
    )
      @target_dataset_geo_id = target_dataset_geo_id
      @source_data_year = source_data_year
      @source_dataset_geo_ids = source_dataset_geo_ids
      @target_area_name = target_area_name
      @target_country_name = target_country_name
      @migration_slug = migration_slug

      # Infer operation type
      @operation_type = infer_operation_type

      # Validate whether all required arguments are present
      validate_input

      # Set defaults for any non-mandatory arguments that were omitted
      set_defaults

      # Handle both cases where source_dataset_geo_ids is an array or a single ID
      @source_datasets = if @source_dataset_geo_ids.is_a?(Array)
                           Dataset.where(geo_id: @source_dataset_geo_ids)
                         else
                           Dataset.where(geo_id: [@source_dataset_geo_ids])
                         end
    end

    def result
      if @operation_type == :combine
        @result ||= processor.perform(@source_datasets)
      elsif @operation_type == :separate
        @result ||= processor.perform(@target_dataset, @source_datasets.first)
      end
    end

    def export_data
      Amalgamator::DatasetExporter.new(
        target_dataset_geo_id: @target_dataset_geo_id,
        target_area_name: @target_area_name,
        target_country_name: @target_country_name,
        migration_slug: @migration_slug,
        combined_item_values: result,
        source_area_names: @source_datasets.pluck(:name)
      ).perform
    end

    private

    def infer_operation_type
      # Infer operation type based on the type of source_dataset_geo_ids
      @source_dataset_geo_ids.is_a?(Array) ? :combine : :separate
    end

    # Updated validation to handle single or multiple source geo-IDs
    def validate_input
      # Check for missing mandatory arguments
      empty_args = {
        target_dataset_geo_id: @target_dataset_geo_id,
        source_data_year: @source_data_year,
        source_dataset_geo_ids: @source_dataset_geo_ids
      }.select { |_arg, v| v.blank? }

      if empty_args.present?
        argument_error("The following mandatory arguments were omitted: #{empty_args.keys.join(', ')}")
      end

      # Check target_dataset_geo_id
      unless @target_dataset_geo_id.present? && @target_dataset_geo_id.is_a?(String)
        argument_error('The target_dataset_geo_id should be a (numeric) string')
      end

      @target_dataset = Dataset.find_by(geo_id: @target_dataset_geo_id)

      # No target_area_name was provided, so we should derive it from an existing dataset
      # with the given 'target_dataset_geo_id'. We raise an error if we can't.
      if @target_area_name.blank? && (@target_dataset.nil? || @target_dataset.name.blank?)
        argument_error('No target_area_name was provided, and it cannot be derived through the target_dataset_geo_id')
      end

      # Check if the source_data_year lies between 1900 and the current year.
      unless @source_data_year.to_i.between?(1900, Time.zone.today.year)
        argument_error("The source_data_year provided is not a valid year. A valid year is between 1900 and #{Time.zone.today.year}")
      end

      # Updated source_dataset_geo_ids validation for combiner vs separator
      unless (@source_dataset_geo_ids.is_a?(Array) && @source_dataset_geo_ids.all? { |id| id.is_a?(String) }) ||
             (@source_dataset_geo_ids.is_a?(String) && !@source_dataset_geo_ids.blank?)
        argument_error('The source_dataset_geo_ids should be a set of ids or a single id')
      end
    end

    def validate_dataset_data_year
      if @source_datasets.empty?
        argument_error('Could not find any datasets for the given source_dataset_geo_ids')
      end

      outdated_datasets = @source_datasets.select do |set|
        set.editable_attributes.find('analysis_year').value.to_i < @source_data_year.to_i
      end

      if outdated_datasets.present?
        argument_error(
          "The following datasets are not up to date to the requested source_data_year (#{@source_data_year}):\n" \
          "#{outdated_datasets.pluck(:name).join(', ')}\n"
        )
      end
    end

    # Updated default setting logic
    def set_defaults
      # No target_area_name was provided. Derive it from the target dataset.
      if @target_area_name.blank?
        @target_area_name = @target_dataset.name
      end

      # No target_country_name was provided, but it is required. Derive it from the target dataset.
      if @target_country_name.blank? && @target_dataset_geo_id.start_with?('PV', 'RES')
        @target_country_name = @target_dataset.country
      end
    end

    def argument_error(msg)
      raise ArgumentError, "#{msg}. Aborting."
    end
  end
end
