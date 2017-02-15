module DatasetHelper
  def dataset_value_for(key, val)
    if edit = @dataset_edits.find(key)
      edit.value
    else
      val
    end
  end
end
