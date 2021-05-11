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

  # Public: Takes a GitFiles::GitFile and returns the URL to view the file on GitHub.
  def github_file_path(file)
    "https://github.com/quintel/etsource/tree/master/#{file.git_path}"
  end

  def format_file_description(description)
    # rubocop:disable Rails/OutputSafety
    simple_format(description).gsub('<br />', '').html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def git_file_info_path(dataset, element, file)
    git_file_info_dataset_path(
      id: dataset.geo_id,
      interface_element_key: element.key,
      file_key: file.relative_path
    )
  end
end
