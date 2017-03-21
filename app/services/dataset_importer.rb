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
    end

    provinces.each do |key|
      dataset = Dataset.find_or_create_by(geo_id: key.downcase)
      dataset.area = key.downcase
      dataset.save
    end
  end

  private

  def provinces
    dataset.group_by { |row| row['province'] }.keys
  end

  def dataset
    CSV.read(Rails.root.join("db", "datasets", "#{ @country }_datasets.csv"),
      headers: true)
  end
end
