class VersionsController < ApplicationController
  before_action :assign_freeze_date_to_thread

  def update
    version_name = params[:version_name]
    freeze_date  = fetch_version_freeze_date(version_name)

    if freeze_date.nil?
      return render json: { error: "Version not found." }, status: :not_found
    end

    session[:freeze_date] = freeze_date

    datasets = Dataset.all
    results = []

    datasets.each do |dataset|
      dataset.set_freeze_date(freeze_date)

      dataset_info = {
        id: dataset.id,
        name: dataset.name,
        attributes: dataset.editable_attributes.as_json
      }

      results << dataset_info
    end

    render json: {
      version: version_name,
      freeze_date: freeze_date,
      updated_datasets: results
    }
  end

  private

  def versions_config
    @versions_config ||= YAML.load_file(Rails.root.join('config', 'versions.yml'))['versions']
  end

  def fetch_version_freeze_date(version_name)
    version = versions_config.find { |v| v['name'] == version_name }
    return unless version

    if version['freeze_date'].present?
      Time.parse(version['freeze_date'])
    else
      Time.now
    end
  end

  def assign_freeze_date_to_thread
    Thread.current[:global_freeze_date] = session[:freeze_date]
  end
end
