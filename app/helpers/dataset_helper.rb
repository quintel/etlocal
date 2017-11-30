module DatasetHelper
  def has_dataset_edit_by_robot?(dataset_edit)
    dataset_edit.latest.present? && dataset_edit.latest.user == User.robot
  end

  def filename_for_source
    if params[:change] && params[:change][:source_attributes]
      params[:change][:source_attributes][:source_file].original_filename
    else
      I18n.t("datasets.attributes.no_source_file")
    end
  end

  def download_button_disabled?(dataset)
    !Transformer::DatasetCast.new(dataset.editable_attributes.as_json).valid?
  end
end
