class DatasetEditCollection
  def self.for(dataset_area)
    new(DatasetEdit
          .joins(:commit)
          .where("`commits`.`dataset_area` = ?", dataset_area)
          .sorted)
  end

  def initialize(dataset_edits)
    @dataset_edits = dataset_edits
  end

  def all
    @dataset_edits
  end

  def previous(key)
    @dataset_edits.select { |edit| edit.key == key }
  end

  def find(key)
    previous(key.to_s).first
  end

  def value_for(key)
    if edit = find(key)
      edit.value.to_f
    end
  end

  def last
    all.first
  end
end
