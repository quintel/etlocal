class DatasetDownloader
  def initialize(dataset)
    @dataset             = dataset
    @editable_attributes = dataset.editable_attributes
    @area_name           = dataset.temp_name
  end

  def validator
    @validator ||= Transformer::DatasetCast.new(@editable_attributes.as_json)
  end

  def download
    begin
      Dataset::Scaler.scale!(@dataset, @dataset.editable_attributes.as_json)
      Dataset::Analyzer.analyze!(@dataset, @dataset.editable_attributes.as_json)
      move_dataset_to_temp!
      compress_dataset!
      File.read(zip_file_path.to_s)
    ensure
      remove_temporary_files
    end
  end

  def zip_filename
    "#{ @area_name }.zip"
  end

  private

  # Analyzing
  # Moving
  def move_dataset_to_temp!
    FileUtils.mv(
      Pathname.new(Atlas.data_dir).join('datasets', @area_name),
      tmp_folder
    )
  end

  # Compressing
  def compress_dataset!
    Archive::Zip.archive(zip_file_path.to_s, dataset_tmp_folder.to_s)
  end

  # Removing
  def remove_temporary_files
    FileUtils.rm_rf(dataset_tmp_folder)
    FileUtils.rm(zip_file_path)
  end

  def zip_file_path
    tmp_folder.join(zip_filename)
  end

  def dataset_tmp_folder
    tmp_folder.join(@area_name)
  end

  def tmp_folder
    Rails.root.join('tmp')
  end
end
