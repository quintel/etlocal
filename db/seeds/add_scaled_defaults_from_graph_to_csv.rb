require 'progress_bar'
require_relative './graph_assumptions'
require_relative './dataset_importer/dataset_csv_row'

class AddScaledDefaultsFromGraphToCSV
  def initialize(country)
    @country = country.to_sym
  end

  def run!
    atlas_ds = Atlas::Dataset.find(@country)
    graph    = Atlas::Runner.new(atlas_ds).calculate
    scope    = Dataset.where(public: true, user: User.robot)
    bar      = ProgressBar.new(scope.count)

    CSV.open('test.csv', 'wb', write_headers: true, headers: headers) do |csv|
      datasets.each do |dataset|
        row = DatasetImporter::DatasetCSVRow.new(dataset.to_h)
        ar_dataset = scope.find_by(geo_id: row.geo_id)
        assumptions = GraphAssumptions.get(atlas_ds, graph, ar_dataset)

        csv << dataset.fields + assumptions

        bar.increment!
      end
    end
  end

  private

  def headers
    datasets.headers + InterfaceElement.items.reject(&:flexible).map { |i| i.key.to_s }
  end

  def datasets
    @datasets ||= CSV.read(path, headers: true)
  end

  def path
    Rails.root.join("db", "datasets", "#{ @country }_datasets.csv")
  end
end

AddScaledDefaultsFromGraphToCSV.new(ENV['COUNTRY']).run! if ENV['COUNTRY']
