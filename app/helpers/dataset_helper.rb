module DatasetHelper
  def dataset_value_for(key)
    (edit_for_key(key) || @dataset.public_send(key))
  end

  def edit_for_key(key)
    edit = @dataset_edits.find(key)

    edit && edit.value.to_f
  end

  def has_dataset_edit?(key)
    @dataset_edits.find(key).present?
  end

  def unit_for(attribute)
    @dataset.editable_attributes.detect{ |t| t.key == attribute.key }.unit
  end

  def filename_for_source
    if params[:change] && params[:change][:source_attributes]
      params[:change][:source_attributes][:source_file].original_filename
    else
      I18n.t("datasets.attributes.no_source_file")
    end
  end
end
