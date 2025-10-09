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
    "https://github.com/quintel/etsource/tree/master/#{file.real_relative_path}"
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

  def options_for_parent_select
    parents = ['any'] + Dataset.all.map(&:actual_parent).uniq
    options_for_select(parents.map { |c| [I18n.t("countries.#{c}"), c] }, 'any')
  end

  def interface_item_value(form, interface_item, dataset = nil)
    value = form.object.public_send(interface_item.key) rescue nil
    if value.nil? && dataset&.respond_to?(interface_item.key)
      value = dataset.public_send(interface_item.key)
    end
    value
  end

  def display_unit_for(interface_item)
    return if interface_item.unit == 'string' || interface_item.unit == 'boolean'
    I18n.t("units.#{ interface_item.key }.from", default: interface_item.unit)&.html_safe
  end

  def format_display_value(value, interface_item)
    return I18n.t('datasets.missing_value') if value.nil?

    case interface_item.unit
    when 'string'
      value
    when 'boolean'
      value == true || value == 1 ? 'True' : 'False'
    else
      if interface_item.key == :analysis_year
        value.round
      elsif interface_item.unit == '€'
        number_to_currency(value, precision: 0, unit: '')
      else
        number_with_precision(value, precision: interface_item.precision, strip_insignificant_zeros: true)
      end
    end
  end

  def item_editable?(dataset, interface_item)
    policy(dataset).edit? && interface_item.editable?(dataset)
  end

  def boolean_checked?(value)
    value == true || value == 1
  end

  def slider_data_attributes(interface_item, dataset)
    {
      key: interface_item.key,
      flexible: ('flex' if interface_item.flexible),
      editable: (item_editable?(dataset, interface_item) ? '1' : '0')
    }
  end

  def data_source_message_key(dataset, interface_element)
    if I18n.exists?("data_source_messages.#{dataset.data_source}.#{interface_element.key}")
      "data_source_messages.#{dataset.data_source}.#{interface_element.key}"
    else
      "data_source_messages.#{dataset.data_source}.default"
    end
  end

  def show_github_link?(dataset)
    I18n.exists?("data_source_messages.#{dataset.data_source}.view_file")
  end

  def github_dataset_url(dataset)
    "https://github.com/quintel/etlocal/blob/production/data/datasets/#{dataset.geo_id}.csv"
  end
end
