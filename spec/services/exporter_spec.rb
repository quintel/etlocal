require 'rails_helper'
require 'support/graph'

describe Exporter do
  let(:dataset) { FactoryBot.create(:dataset) }

  let!(:stub_export_request) {
    stub_request(:get, "https://beta-local.energytransitionmodel.com/api/v1/exports/#{dataset.id}")
      .to_return(body: JSON.dump([{
        'area' => 'test1_ameland',
        'country' => 'nl',
        'electricity_consumption' => 500,
        'gas_consumption' => 500,
        'roof_surface_available_for_pv' => 500,
        'present_number_of_apartments_before_1945' => 84,
        'present_number_of_apartments_before_1945_with_solar_pv' => 1,
        'number_of_cars' => 10,
        'number_of_inhabitants' => 10,
        'percentage_of_old_residences' => 10,
        'building_area' => 20,
        'electricity_consumption_buildings' => 1,
        'gas_consumption_buildings' => 1,
        'has_industry' => true,
        'has_agriculture' => true
      }]))
  }

  it "exports a dataset" do
    Exporter.export(dataset.id, rebuild: false)

    expect(Atlas::Dataset::Derived.find('test1_ameland').number_of_cars).to eq(10)
  end

  # Reset values to old values
  after(:all) do
    ameland = Atlas::Dataset::Derived.find('test1_ameland')
    ameland.attributes = { number_of_cars: 1062.598515994393 }
    ameland.save
  end
end
