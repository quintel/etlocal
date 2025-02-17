class VersionsController < ApplicationController

  def update
    version_name = params[:version_name]
    freeze_date = fetch_version_freeze_date(version_name)

    if freeze_date.nil?
      return render json: { error: "Version not found." }, status: :not_found
    end

    datasets = Dataset.find(18562) #Dataset.all TODO: Change back, just testing one dataset for now
    datasets = [datasets]
    results = []

    datasets.each do |dataset|
      dataset_info = {
        id: dataset.id,
        name: dataset.name,
        attributes: {}
      }

      EditableAttributesCollection.items.each do |item|
        key = item.key.to_s
        next unless item.editable?(dataset)

        edits_array = dataset
          .editable_attributes
          .instance_variable_get(:@edits)[key]

        next unless edits_array

        Rails.logger.debug "Edits for #{key}: #{edits_array.class} - #{edits_array.inspect}"

        begin
          attribute_obj = EditableAttribute.new(dataset, key, edits_array)
          new_value = attribute_obj.value(freeze_date)
          dataset_info[:attributes][key] = new_value
        rescue StandardError => e
          Rails.logger.error "⚠️ Error processing key #{key}: #{e.message}"
          next
        end
      end

      results << dataset_info
    end

    render json: { version: version_name, freeze_date:, updated_datasets: results }
  rescue StandardError => e
    Rails.logger.error "🚨 Fatal error in update: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    render json: { error: "Internal Server Error", details: e.message }, status: :internal_server_error
  end

  private

  def versions_config
    @versions_config ||= YAML.load_file(Rails.root.join('config', 'versions.yml'))['versions']
  end

  def fetch_version_freeze_date(version_name)
    version = versions_config.find { |v| v['name'] == version_name }
    version ? (version['freeze_date'] ? Time.parse(version['freeze_date']) : Time.now) : nil
  end

  def value_at_version(version_name)
    freeze_date = fetch_version_freeze_date(version_name)
    value(freeze_date)
  end
end
