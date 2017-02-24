class Dataset
  include AttributeCollection
  include GoogleMaps

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

  def dataset_edits
    DatasetEditCollection.for(area)
  end
end
