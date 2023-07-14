# frozen_string_literal: true

class DatasetCombiner

  # Arguments:
  #   target_dataset_geo_id: Identifier of dataset to combine into, e.g.: 'PV20'
  #   source_data_year: The year over which new data should be calculated
  #   source_dataset_geo_ids: Identifiers for areas to be combined, e.g.: ['GM306','GM307']
  #   target_area_name (optional): Name of combined area, e.g.: 'Groningen'
  #   migration_slug (optional): Short description of migration in lowercase and underscores, e.g.: 'update_2023'
  def initialize(target_dataset_geo_id:, source_data_year:, source_dataset_geo_ids:, target_area_name: nil, migration_slug: nil)
    @target_dataset_geo_id = target_dataset_geo_id
    @source_data_year = source_data_year
    @source_dataset_geo_ids = source_dataset_geo_ids
    @target_area_name = target_area_name
    @migration_slug = migration_slug

    # Validate whether all required arguments are present
    validate_input

    # Set defaults for any non-mandatory arguments that were omitted
    set_defaults

    @source_datasets = Dataset.where(geo_id: @source_dataset_geo_ids)

    # Validate whether all source datasets are up to date until at least the requested source_data_year
    validate_dataset_data_year
  end

  def combine_datasets
    @combined_item_values = DatasetCombiner::ValueProcessor.perform(@source_datasets)
  end

  def export_data
    DatasetCombiner::DataExporter.new(
      target_dataset_geo_id: @target_dataset_geo_id,
      target_area_name: @target_area_name,
      migration_slug: @migration_slug,
      combined_item_values: @combined_item_values,
      source_area_names: @source_datasets.pluck(:name)
    ).perform
  end

  private

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
    unless @target_dataset_geo_id.is_a?(String)
      argument_error('The target_dataset_geo_id should be a (numeric) string')
    end

    # Check source_data_year
    if /^(19|20|21)\d{2}$/.match(@source_data_year.to_s).blank?
      argument_error('The source_data_year provided is not a valid year. A valid year is between 1900 and 2199')
    end

    # Check source_dataset_geo_ids
    unless @source_dataset_geo_ids.is_a?(Array) && @source_dataset_geo_ids.all? { |id| id.is_a?(Numeric) || id.is_a?(String) }
      argument_error('The source_dataset_geo_ids should be a set of ids')
    end
  end

  def validate_dataset_data_year
    if @source_datasets.empty?
      argument_error('Could not find datasets for the given source_dataset_geo_ids')
    end

    outdated_datasets = @source_datasets.select do |set|
      set.editable_attributes.find('analysis_year').value.to_i < @source_data_year
    end

    if outdated_datasets.present?
      argument_error(
        "The following datasets are not up to date to the requested source_data_year (#{@source_data_year}):\n
        #{outdated_datasets.pluck(:name).join(', ')}\n"
      )
    end
  end

  def set_defaults
    # No target_area_name was provided. Attempt to derive it from the given target_dataset_geo_id
    if @target_area_name.blank?
      target_dataset = Dataset.find_by(geo_id: @target_dataset_geo_id)

      if target_dataset.nil? || target_dataset.name.blank?
        argument_error('No target_area_name was provided, and it could not be derived through the target_dataset_geo_id')
      end

      @target_area_name = target_dataset.name
    end

    # No migration slug was provided. Derive it from the given source_data_year
    if @migration_slug.blank?
      @migration_slug = @source_data_year.to_s
    end
  end

  def argument_error(msg)
    raise ArgumentError, "#{msg}. Aborting."
  end

end
