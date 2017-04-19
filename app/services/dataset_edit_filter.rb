class DatasetEditFilter
  def initialize(dataset, commit)
    @dataset = dataset
    @commit  = commit
  end

  def changed_edits
    @commit.dataset_edits.select do |edit|
      previous_edit = @dataset.editable_attributes.find(edit.key)

      !previous_edit || edit.value != previous_edit.value
    end
  end

  def include?(key)
    changed_edits.map(&:key).include?(key)
  end
end
