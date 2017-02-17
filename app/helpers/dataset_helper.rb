module DatasetHelper
  def dataset_value_for(key)
    edit = @dataset.dataset_edits.find(key)

    edit && edit.value || @dataset.original_value_for(key)
  end

  def has_dataset_edit?(key)
    @dataset.dataset_edits.find(key).present?
  end

  def is_boolean_field?(key)
    value = @dataset.original_value_for(key)

    !!value == value
  end
end
