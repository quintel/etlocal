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

  def previous(key)
    @dataset_edits.select { |edit| edit.key == key }.reverse
  end

  def find(key)
    previous(key.to_s).first
  end
end
