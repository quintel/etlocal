class RetireGm0345haHetAmbachtVeenendaal < ActiveRecord::Migration[7.0]

  # Destroy dataset and save dataset attributes to temporary file for
  # migration rollback purposes
  def up
    dataset = Dataset.find_by(geo_id: 'GM0345HA')
    save_deleted_datasets([dataset.attributes].to_json) if dataset&.destroy
  end

  # Functionality for rollback purposes where removed data is restored to the
  # deleted datasets
  def down
    return unless deleted_datasets.any?

    deleted_datasets.each { |attrs| Dataset.create!(attrs.symbolize_keys) }
  end

  private

  def save_deleted_datasets(deleted_datasets)
    File.write(Rails.root.join('tmp', 'deleted_datasets.json'), deleted_datasets)
  end

  def deleted_datasets
    @deleted_datasets ||= JSON.parse(File.read(Rails.root.join('tmp', 'deleted_datasets.json')))
  end
end
