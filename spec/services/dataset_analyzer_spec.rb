require 'rails_helper'

describe DatasetAnalyzer do
  describe "faulty information" do
    it 'can only analyze with a complete set of data' do
      expect{ DatasetAnalyzer.analyze({}) }.to raise_error(ArgumentError)
    end

    it 'can only analyze with the correct keys' do
      expect {
        DatasetAnalyzer.analyze({'non_existing_key' => 5.0 })
      }.to raise_error(ArgumentError)
    end

    it 'only works with numbers' do
      expect {
        DatasetAnalyzer.analyze({
          "gas_consumption" => 5.0,
          "electricity_consumption" => 5.0,
          "roof_surface_available_for_pv" => 5.0,
          "number_of_cars" => 5.0,
          "number_of_residences" => 5.0,
          "number_of_inhabitants" => "test"
        })
      }.to raise_error(ArgumentError)
    end
  end

  describe "correct working" do
    let(:inputs) {
      {
        "gas_consumption" => 5.0,
        "electricity_consumption" => 5.0,
        "roof_surface_available_for_pv" => 5.0,
        "number_of_cars" => 5.0,
        "number_of_residences" => 5.0,
        "number_of_residences_with_solar_pv" => 5.0,
        "number_of_inhabitants" => 5.0
      }
    }

    it 'spews out attributes of a local dataset' do
      analyzer = DatasetAnalyzer.analyze(inputs)
      inputs.slice(:number_of_residences, :number_of_cars, :number_of_inhabitants).each do |key, val|
        expect(analyzer[key]).to eq(val)
      end
    end
  end
end
