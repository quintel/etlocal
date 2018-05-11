require 'progress_bar'
require_relative './graph_assumptions'
require_relative './dataset_importer/dataset_csv_row'

class AddScaledDefaultsFromGraphToCSV
  STATIC_HEADERS = %w(
    type
    province_code
    municipality_code
    district_code
    neighborhood_code
    area_name
    province
    municipality
    district_code_2
    district
    number_of_inhabitants
    number_of_residences
    number_of_cars
    electricity_consumption
    gas_consumption
    heat_consumption
    roof_surface_available_for_pv
  )

  def initialize(country)
    @country = country.to_sym
  end

  def run!
    atlas_ds = Atlas::Dataset.find(@country)
    graph    = Atlas::Runner.new(atlas_ds).calculate
    bar      = ProgressBar.new(datasets.count)

    CSV.open("#{@country}_datasets.csv", 'wb', write_headers: true, headers: headers) do |csv|
      datasets.each do |dataset|
        csv << (
          dataset.values_at(*STATIC_HEADERS) +
          GraphAssumptions.get(atlas_ds, graph, dataset)
        )

        bar.increment!
      end
    end
  end

  private

  def headers
    STATIC_HEADERS + InterfaceElement.items.reject(&:skip_validation).map { |i| i.key.to_s }
  end

  def datasets
    @datasets ||= CSV.read(path, headers: true)
  end

  def path
    Rails.root.join("db", "datasets", "#{ @country }_datasets.csv")
  end
end

AddScaledDefaultsFromGraphToCSV.new(ENV['COUNTRY']).run! if ENV['COUNTRY']
