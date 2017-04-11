class DatasetEditFilter
  def initialize(commit, dataset_edits)
    @commit        = commit
    @dataset_edits = dataset_edits
  end

  def changed_edits
    @commit.dataset_edits.select do |edit|
      previous_edit = @dataset_edits.find(edit.key)

      !previous_edit || edit.value != previous_edit.value
    end
  end

  def include?(key)
    changed_edits.map(&:key).include?(key)
  end
end
