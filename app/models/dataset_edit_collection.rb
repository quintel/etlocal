class DatasetEditCollection
  def self.for(area)
    new(DatasetEdit.where(area: area))
  end

  def initialize(dataset_edits)
    @dataset_edits = dataset_edits
  end

  def all
    @dataset_edits
  end

  def find(key)
    @dataset_edits.where(key: key).last
  end
end
