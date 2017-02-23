class DatasetEditCollection
  def self.for(dataset_area)
    new(Commit.where(dataset_area: dataset_area).flat_map(&:dataset_edits))
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

  def latest
    all.first
  end
end
