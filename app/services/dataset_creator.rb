class DatasetCreator
  def self.create(area)
    new(area).create
  end

  def initialize(area, full_dataset = 'nl')
    @area         = area
    @full_dataset = full_dataset

    raise ArgumentError, "area config does not exist" unless area_config
    raise ArgumentError, "invalid area config" unless area_config_valid?
  end

  def create
    Atlas::Scaler.new(
      @full_dataset, @area, area_config.fetch("number_of_residences")
    ).create_scaled_dataset

    Exporter.store(@area, dataset_edits)
  end

  private

  def dataset_edits
    area_config.each_pair do |key, value|
      DatasetEdit.create!(
        key:    key,
        value:  value,
        commit: Commit.new(commit_attributes)
      )
    end
  end

  def commit_attributes
    { dataset_area: @area, user: User.robot, message: "Initial value" }
  end

  def area_config
    areas[@area]
  end

  def area_config_valid?
    Dataset::EDITABLE_ATTRIBUTES.keys.all? do |attribute|
      area_config[attribute].present? && area_config[attribute].is_a?(Numeric)
    end
  end

  def areas
    @areas ||= Dir["#{ Rails.configuration.area_files }/*.yml"].each_with_object({}) do |path, object|
      object[File.basename(path, '.yml')] = YAML.load_file(path)
    end
  end
end
