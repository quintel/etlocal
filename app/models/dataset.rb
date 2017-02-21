class Dataset
  ATLAS_ATTRIBUTES = %i(base_dataset analysis_year area id)

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

  def editable_attributes
    @atlas_dataset.send(:attribute_set).select do |attribute|
      [Axiom::Types::Float, Axiom::Types::Boolean].include?(attribute.type)
    end
  end

  def inputs
    Input.all.map(&:key)
  end

  def dataset_edits
    DatasetEditCollection.for(id)
  end
end
