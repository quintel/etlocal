module DatasetHelper
  def dataset_value_for(key)
    edit_for_key(key) || @dataset.atlas_dataset.public_send(key)
  end

  def dataset_input_value_for(key)
    edit_for_key(key) || @dataset.atlas_dataset.init[key.to_sym]
  end

  def edit_for_key(key)
    edit = @dataset_edits.find(key)

    edit && edit.value
  end

  def has_dataset_edit?(key)
    @dataset_edits.find(key).present?
  end

  def is_area_attribute?(key)
    @dataset.editable_attributes.map(&:name).include?(key.to_sym)
  end

  def is_boolean_field?(key)
    value = @dataset.atlas_dataset.public_send(key)

    !!value == value
  end
end
