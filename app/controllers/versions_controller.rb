class VersionsController < ApplicationController

  def update
    version_name = params[:version_name]
    freeze_date = fetch_version_freeze_date(version_name)

    return render json: { error: "Version not found or has no freeze date." }, status: :not_found unless freeze_date

    datasets = Dataset.all

    datasets.each do |dataset|
      previous_values = dataset.editable_attributes.as_json

      EditableAttributesCollection.items.each do |item|
        key = item.key.to_s
        next unless item.editable?(dataset)

        editable_attribute = dataset.editable_attributes.find(key)
        next unless editable_attribute

        closest_edit = find_closest_edit(editable_attribute, freeze_date)
        next unless closest_edit

        if previous_values[key] != closest_edit.value
          apply_edit(editable_attribute, closest_edit.value)
        end
      end

      unless dataset.save
        return render json: { error: "Failed to update dataset #{dataset.id}.", details: dataset.errors.full_messages }, status: :unprocessable_entity
      end
    end

    render json: { message: "All datasets updated to match freeze date." }
  end

  private

  def versions_config
    @versions_config ||= YAML.load_file(Rails.root.join('config', 'versions.yml'))['versions']
  end

  def fetch_version_freeze_date(version_name)
    version = versions_config.find { |v| v['name'] == version_name }
    version ? (version['freeze_date'] ? Time.parse(version['freeze_date']) : Time.now) : nil
  end

  def find_closest_edit(editable_attribute, freeze_date)
    editable_attribute.previous
      .select { |edit| edit.updated_at <= freeze_date }
      .min_by { |edit| (freeze_date - edit.updated_at).abs }
  end

  def apply_edit(editable_attribute, value)
    edit = editable_attribute.latest || EditableAttribute.new(@dataset, editable_attribute.key, [])
    edit.value = value
    editable_attribute.previous.unshift(edit)
  end
end
