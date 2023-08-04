# frozen_string_literal: true

# The DatasetCombiner parent class acts as the interface through which smaller areas can be
# combined into a bigger one. It validates user input, sets defaults and then delegates the work
# to the ValueProcessor and DataExporter that do the actual combining.
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
class DatasetCombiner

  # Arguments:
  #   target_dataset_geo_id: Identifier of dataset to combine into, e.g.: 'PV20'
  #   source_data_year: The year over which new data should be calculated
  #   source_dataset_geo_ids: Identifiers for areas to be combined, e.g.: ['GM306','GM307']
  #   target_area_name (optional): Name of combined area, e.g.: 'Groningen'
  #   target_country_name (optional): Name of country of the target dataset, e.g. 'nl2019'
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
      target_country_name: @target_country_name,
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
    unless @target_dataset_geo_id.present? && @target_dataset_geo_id.is_a?(String)
      argument_error('The target_dataset_geo_id should be a (numeric) string')
    end

    @target_dataset = Dataset.find_by(geo_id: @target_dataset_geo_id)

    # No target_area_name was provided, so we should derive it from an existing dataset
    # with the given 'target_dataset_geo_id'. We raise an error if we can't.
    if @target_area_name.blank? && (@target_dataset.nil? || @target_dataset.name.blank?)
      argument_error('No target_area_name was provided, and it cannot be derived through the target_dataset_geo_id')
    end

    # If the target dataset is a province or RES region we need to include a country name.
    # This should either be passed as the 'target_country_name' argument, or be derived
    # from the dataset that belongs to the given 'target_dataset_geo_id'.
    # We raise an error if this is not the case.
    if @target_dataset_geo_id.start_with?('PV', 'RES') && @target_country_name.blank? && @target_dataset.nil?
      argument_error(
        <<~MSG
          You are attempting to create a combined dataset for a province or RES-region which required a country name.
          The country name could not be derived from an existing dataset with geo-id '#{@target_dataset_geo_id}' however.
          Please pass the country name as the "target_country_name" argument.\n
        MSG
      )
    end

    # Check if the source_data_year lies between 1900 and the current year.
    unless @source_data_year.to_i.between?(1900, Time.zone.today.year)
      argument_error("The source_data_year provided is not a valid year. A valid year is between 1900 and #{Time.zone.today.year}")
    end

    # Check source_dataset_geo_ids
    unless @source_dataset_geo_ids.is_a?(Array) && @source_dataset_geo_ids.all? { |id| id.is_a?(String) }
      argument_error('The source_dataset_geo_ids should be a set of ids')
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
        "The following datasets are not up to date to the requested source_data_year (#{@source_data_year}):\n
        #{outdated_datasets.pluck(:name).join(', ')}\n"
      )
    end
  end

  def set_defaults
    # No target_area_name was provided. Derive it from the target dataset.
    if @target_area_name.blank?
      @target_area_name = @target_dataset.name
    end

    # No target_country_name was provided, but it is required. Derive it from the target dataset.
    if @target_country_name.blank? && @target_dataset_geo_id.start_with?('PV', 'RES')
      @target_country_name = @target_dataset.country
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
