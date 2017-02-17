class Dataset
  attr_reader :atlas_dataset

  def self.all
    Etsource.collection
  end

  def self.find(area)
    all.detect { |dataset| dataset.area == area }
  end

  def self.find_by_id(id)
    all.detect { |dataset| dataset.id == id }
  end

  def initialize(atlas_dataset)
    @atlas_dataset = atlas_dataset
  end

  def area
    @atlas_dataset.area
  end

  def id
    @atlas_dataset.id
  end

  def editable_attributes
    @atlas_dataset.send(:attribute_set).select do |attribute|
      [Axiom::Types::Float, Axiom::Types::Boolean].include?(attribute.type)
    end
  end

  def dataset_edits
    DatasetEditCollection.for(id)
  end

  def original_value_for(key)
    atlas_dataset.init[key.to_sym] ||
    atlas_dataset.public_send(key)
  end
end
