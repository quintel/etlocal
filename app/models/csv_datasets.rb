module CSVDatasets
  def self.all
    csv_file.map do |row|
      Dataset.new(geo_id: nil)
    end
  end

  private

  def self.csv_file
    @csv_file ||= CSV.read(
      Rails.root.join("db", "datasets", "nl_datasets.csv"),
      headers: true)
  end
end
