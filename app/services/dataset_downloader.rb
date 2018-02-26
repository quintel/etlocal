class DatasetDownloader
  def initialize(dataset)
    @area_name = dataset.temp_name
    @attributes = dataset.editable_attributes.as_json.merge(
      area: @area_name,
      base_dataset: dataset.country
    )
  end

  def download
    Transformer::DatasetGenerator.new(@attributes).generate(
      [ Transformer::DatasetGenerator::Validator ]
    )

    Archive::Zip.archive(zip_file_path.to_s, dataset_dir.to_s)
    File.read(zip_file_path.to_s)
  end

  # Removing
  def prune!
    return unless File.directory?(dataset_dir)

    FileUtils.rm_rf(dataset_dir)
    FileUtils.rm(zip_file_path)
  end

  def zip_filename
    "#{ @area_name }.zip"
  end

  private

  def dataset_dir
    Pathname.new(Atlas.data_dir).join('datasets', @area_name)
  end

  def zip_file_path
    Rails.root.join('tmp').join(zip_filename)
  end
end
