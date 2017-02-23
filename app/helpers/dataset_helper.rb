module DatasetHelper
  def dataset_value_for(key)
    edit_for_key(key) || @dataset.public_send(key)
  end

  def edit_for_key(key)
    edit = @dataset_edits.find(key)

    edit && edit.value
  end

  def has_dataset_edit?(key)
    @dataset_edits.find(key).present?
  end

  def is_boolean_field?(key)
    value = @dataset.public_send(key)

    !!value == value
  end

  def is_boolean_value?(value)
    value.to_s =~ /true|false/
  end
end
