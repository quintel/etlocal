class VersionsController < ApplicationController

  def update
    version_name = params[:version_name]
    freeze_date = fetch_version_freeze_date(version_name)

    if freeze_date.nil?
      render json: { error: "Invalid version selected" }, status: :unprocessable_entity
      return
    end

    # Reapply commits up to the freeze date to "remigrate" datasets
    remigrate_datasets(freeze_date)

    render json: { message: "Datasets updated to version #{version_name}" }
  end

  private

  # Reads versions from the config file
  def fetch_version_freeze_date(version_name)
    versions = YAML.load_file(Rails.root.join('config/versions.yml'))['versions']
    version = versions.find { |v| v['name'] == version_name }
    return version ? (version['freeze_date'] ? Time.zone.parse(version['freeze_date']) : nil) : nil
  rescue Errno::ENOENT
    nil
  end

  # Applies dataset commits up to the freeze date
  def remigrate_datasets(freeze_date)
    Dataset.find_each do |dataset|
      commits = dataset.commits.where("created_at <= ?", freeze_date).order(:created_at)
      dataset_edits = commits.flat_map(&:dataset_edits)

      dataset_edits.each do |edit|
        dataset.update_column(edit.key, edit.value)
      end
    end
  end
end
