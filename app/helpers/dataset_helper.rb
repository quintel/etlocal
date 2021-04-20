module DatasetHelper
  def version_options
    versions = @dataset_clones

    options_from_collection_for_select(versions, 'id', 'creator').prepend(
      "<option value='' disabled='disabled'>#{I18n.t('datasets.commit.switch_dataset')}</option>".html_safe
    )
  end

  def has_dataset_edit_by_robot?(dataset_edit)
    dataset_edit.latest.present? && dataset_edit.latest.user == User.robot
  end

  def download_button_disabled?(dataset)
    !Transformer::DatasetCast.new(dataset.editable_attributes.as_json).valid?
  end

  def default_unit_for(key)
    if key =~ /share/
      "%"
    else
      ''
    end
  end

  def conversions_for(key)
    {
      to: I18n.t("units.#{ key }.to"),
      from: I18n.t("units.#{ key }.from", default: I18n.t("units.#{ key }.to")).html_safe
    }
  end
end
