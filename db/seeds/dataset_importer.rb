require 'progress_bar'

class DatasetImporter
  def initialize(country = 'nl')
    @country = country
  end

  def import
    bar   = ProgressBar.new(datasets.size)
    scope = Dataset.includes(:edits).each_with_object({}) do |el, hash|
      hash[el.geo_id] = el
    end

    datasets.each do |row|
      dataset_row = DatasetCSVRow.new(row.to_h)
      dataset     = (
        scope[dataset_row.geo_id] ||
        Dataset.create!(geo_id: dataset_row.geo_id, area: dataset_row.area)
      )

      Defaults.set(dataset, dataset_row)

      bar.increment! if Rails.env.development?
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
