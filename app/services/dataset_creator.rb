class DatasetCreator
  def self.create(area)
    new(area).create
  end

  def initialize(area, full_dataset = 'nl')
    @area         = area
    @full_dataset = full_dataset

    raise ArgumentError, "area config does not exist" unless area_config
    unless AttributeValidator.valid?(area_config)
      raise ArgumentError, "invalid area config"
    end
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

  def areas
    @areas ||= Dir["#{ Rails.configuration.area_files }/*.yml"].each_with_object({}) do |path, object|
      object[File.basename(path, '.yml')] = YAML.load_file(path)
    end
  end
end
