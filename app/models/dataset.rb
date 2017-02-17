class Dataset
  def self.all
    Etsource.collection
  end

  def self.find(area)
    all.detect do |dataset|
      dataset.area == area
    end
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

  private

  def dataset_edits
  end
end
