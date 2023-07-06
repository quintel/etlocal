class DatasetCombiner

  # Arguments:
  #   target_dataset_id: Identifier of dataset to combine into, e.g.: 'PV20'
  #   source_data_year: The year over which new data should be calculated
  #   source_dataset_ids: Identifiers for areas to be combined, e.g.: ['GM306','GM307']
  #   target_area_name: Name of combined area, e.g.: 'Groningen'
  #   migration_slug: Short description of migration, e.g.: 'update_2023'
  def initialize(target_dataset_id:, source_data_year:, source_dataset_ids:, target_area_name:, migration_slug:)
    @target_dataset_id = target_dataset_id
    @source_data_year = source_data_year
    @source_dataset_ids = source_dataset_ids
    @target_area_name = target_area_name
    @migration_slug = migration_slug

    # Validate if all required arguments are present
    validate_input

    # Set defaults for any non-mandatory arguments that were omitted
    set_defaults

    @source_datasets = Dataset.where(id: @source_dataset_ids)

    # Validate whether all source datasets are up to date until at least the requested source_data_year
    validate_datasets
  end

  def combine_datasets
    @combined_item_values = Calculator.perform(@source_datasets)
  end

  def export_migrations
    MigrationGenerator.perform(
      target_dataset_id: @target_dataset_id,
      target_area_name: @target_area_name,
      migration_slug: @migration_slug,
      combined_item_values: @combined_item_values,
      source_area_names: @datasets.pluck(:area)
    )
  end

  private

  def validate_input
    raise ArgumentError, 'Error! No target_dataset_id given to combine into. Aborting.' if @target_dataset_id.empty?

    raise ArgumentError, 'Error! No source_data_year was given to check for consistency. Aborting.' if @source_data_year.empty?

    raise ArgumentError, 'Error! No source_dataset_ids given to combine data from. Aborting.' if @source_dataset_ids.empty?
  end

  def validate_datasets
    source_data_years = @source_datasets.select{ |dataset| dataset.analysis_year < @source_data_year }

    if source_data_years.present?
      raise ArgumentError, <<~ERROR_MSG
        Error! The following datasets are not up to date to the requested source_data_year:
          #{source_data_years.pluck(:area)}
        Aborting."
      ERROR_MSG
    end
  end

  def set_defaults
    # No name was passed. Derive it from the given target_dataset_id
    if @area_name.empty?
      # @TODO
    end

    # No migration name was passed. Derive it from the given target_dataset_id and source_data_year
    if @migration_slug.empty?
      # @TODO
    end
  end

end
