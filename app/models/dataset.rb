class Dataset
  include AttributeCollection

  DATASET_MAPS = YAML.load_file(Rails.root.join("config", "maps.yml")).freeze

  def self.all
    Etsource.datasets
  end

  def self.find(area)
    all.detect { |dataset| dataset.area == area }
  end

  def initialize(atlas_dataset)
    @atlas_dataset = atlas_dataset

    set_attributes
  end

  def map_image(size = '200x200')
    options         = DATASET_MAPS[area] || DATASET_MAPS["default"]
    options["size"] = size
    options["key"]  = Rails.configuration.google_maps_api_key

    "https://maps.googleapis.com/maps/api/staticmap?#{ options.to_query }"
  end

  def dataset_edits
    DatasetEditCollection.for(area)
  end
end
