require 'progress_bar'

class DatasetImporter
  def initialize(country = 'nl')
    @country = country
  end

  def import
    bar = ProgressBar.new(datasets.size)

    datasets.each do |row|
      dataset_row = DatasetCSVRow.new(row.to_h)

      unless dataset = Dataset.find_by(geo_id: dataset_row.geo_id)
        dataset = Dataset.find_or_create_by(geo_id: dataset_row.geo_id)
        dataset.area = dataset_row.area
        dataset.save
      end

      Defaults.set(dataset, dataset_row)
      bar.increment!
    end
  end

  private

  def datasets
    @datasets ||= CSV.read(
      Rails.root.join("db", "datasets", "#{ @country }_datasets.csv"),
      headers: true
    )
  end
end
