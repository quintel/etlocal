module DatasetHelper
  def dataset_value_for(key)
    edit = @dataset_edits.find(key)

    edit && edit.value || @dataset.init[key.to_sym] || @dataset.public_send(key)
  end
end
