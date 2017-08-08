class DatasetDownloader
  def initialize(dataset)
    @dataset             = dataset
    @editable_attributes = @dataset.editable_attributes
    @area_name           = area_name
  end

  def validator
    Transformer::AttributeValidator.new(@editable_attributes.as_json)
  end

  def download
    begin
      scale_dutch_dataset!
      analyze_dataset!
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

  # Scaling
  def scale_dutch_dataset!
    Atlas::Scaler
      .new(@dataset.country, @area_name, number_of_residences)
      .create_scaled_dataset
  end

  def number_of_residences
    @editable_attributes.find('number_of_residences').value
  end

  # Analyzing
  def analyze_dataset!
    dataset = Atlas::Dataset::Derived.find(@area_name)
    dataset.attributes = DatasetAnalyzer.analyze(dataset, @editable_attributes.as_json)
    dataset.save
  end

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

  def area_name
    "#{ Time.now.to_i }-#{ @dataset.area.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '') }"
  end
end
