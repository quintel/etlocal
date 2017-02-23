class Dataset
  include AttributeCollection

  DATASET_MAPS = YAML.load_file(Rails.root.join("config", "maps.yml")).freeze

  def self.all
    Etsource.datasets
  end

  def self.find(area)
    all.detect { |dataset| dataset.area == area }
  end

  def self.find_by_id(id)
    all.detect { |dataset| dataset.id == id }
  end

  def initialize(atlas_dataset)
    @atlas_dataset = atlas_dataset

    set_attributes
  end

  def map_image
    options = DATASET_MAPS[area] || DATASET_MAPS["default"]
    options["size"] = "200x200"

    "https://maps.googleapis.com/maps/api/staticmap?#{ options.to_query }"
  end

  def dataset_edits
    DatasetEditCollection.for(id)
  end
end
