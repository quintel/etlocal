class DatasetImporter
  def initialize(country = 'nl')
    @country = country
  end

  def import
    dataset.each do |row|
      dataset_row = DatasetCSVRow.new(row.to_h)

      dataset = Dataset.find_or_create_by(geo_id: dataset_row.geo_id)
      dataset.area = dataset_row.area
      dataset.save

      Defaults.set(dataset, dataset_row)
    end
  end

  private

  def dataset
    CSV.read(Rails.root.join("db", "datasets", "#{ @country }_datasets.csv"),
      headers: true)
  end
end
