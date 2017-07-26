module DatasetHelper
  def has_dataset_edit_by_robot?(dataset_edit)
    dataset_edit.latest.present? && dataset_edit.latest.user == User.robot
  end

  def unit_for(key)
    (Dataset::EDITABLE_ATTRIBUTES[key.to_s] || {})[:unit]
  end

  def filename_for_source
    if params[:change] && params[:change][:source_attributes]
      params[:change][:source_attributes][:source_file].original_filename
    else
      I18n.t("datasets.attributes.no_source_file")
    end
  end

  def slider_group?(group)
    Dataset::EDITABLE_ATTRIBUTES
      .select { |_, opts| opts['slider_group'] }
      .keys.include?(group)
  end

  def toggle_value_for(dataset, key)
    dataset.editable_attributes.find(key).value
  end
end
