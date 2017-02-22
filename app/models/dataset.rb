class Dataset
  ATLAS_ATTRIBUTES = %i(base_dataset analysis_year area id)
  DATASET_MAPS     = YAML.load_file(Rails.root.join("config", "maps.yml")).freeze
  EDITABLE_TYPES   = { booleans: Axiom::Types::Boolean, floats: Axiom::Types::Float }.freeze

  attr_reader :atlas_dataset

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

    ATLAS_ATTRIBUTES.each do |attribute|
      define_singleton_method attribute do
        @atlas_dataset.public_send(attribute)
      end
    end
  end

  def map_image
    options = DATASET_MAPS[area] || DATASET_MAPS["default"]
    options["size"] = "200x200"

    "https://maps.googleapis.com/maps/api/staticmap?#{ options.to_query }"
  end

  def editable_attributes
    attribute_set = @atlas_dataset.send(:attribute_set)

    EDITABLE_TYPES.map do |key, type|
      [key, attribute_set.select { |attr| attr.type == type }]
    end
  end

  def static_attributes
    %i(base_dataset analysis_year)
  end

  def inputs
    Input.sorted
  end

  def dataset_edits
    DatasetEditCollection.for(id)
  end
end
