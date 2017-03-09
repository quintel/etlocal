require 'rails_helper'

describe Exporter do
  let(:dataset) { Dataset.find('ameland') }
  let(:ameland) { Atlas::Dataset::Derived.find('ameland') }

  let!(:stub_export_request) {
    stub_request(:get, "https://beta-local.energytransitionmodel.com/api/v1/exports/ameland")
      .to_return(body: JSON.dump({
        'electricity_consumption' => 500,
        'gas_consumption' => 500,
        'roof_surface_available_for_pv' => 500,
        'number_of_residences' => 10,
        'number_of_residences_with_solar_pv' => 1,
        'number_of_cars' => 10,
        'number_of_inhabitants' => 10,
        'percentage_of_old_residences' => 10
      }))
  }

  it "exports a dataset" do
    Exporter.export(dataset)

    expect(ameland.number_of_cars).to eq(10)
  end

  it "performs analyses of the attributes"

  it "writes to the ad files"

  # Reset values to old values
  after(:all) do
    ameland = Atlas::Dataset::Derived.find('ameland')
    ameland.attributes = { number_of_cars: 1062.598515994393 }
    ameland.save
  end
end
