require 'rails_helper'
require 'support/graph'

describe DatasetAnalyzer do
  let(:dataset) { Atlas::Dataset::Derived.find(:ameland) }

  describe "faulty information" do
    it 'can only analyze with a complete set of data' do
      expect{ DatasetAnalyzer.analyze(dataset, {}) }.to raise_error(ArgumentError)
    end

    it 'can only analyze with the correct keys' do
      expect {
        DatasetAnalyzer.analyze(dataset, {'non_existing_key' => 5.0 })
      }.to raise_error(ArgumentError)
    end

    it 'only works with numbers' do
      expect {
        DatasetAnalyzer.analyze(dataset, {
          "gas_consumption" => 5.0,
          "electricity_consumption" => 5.0,
          "roof_surface_available_for_pv" => 5.0,
          "number_of_cars" => 5.0,
          "number_of_residences" => 5.0,
          "number_of_inhabitants" => "test" # <---
        })
      }.to raise_error(ArgumentError)
    end
  end

  describe "correct working" do
    before do
      graph = Graph.new("dataset_analyzer_base").build

      expect_any_instance_of(Atlas::Runner).to receive(:calculate).and_return(graph)
    end

    let(:inputs) {
      {
        "gas_consumption" => 5.0,
        "electricity_consumption" => 5.0,
        "roof_surface_available_for_pv" => 5.0,
        "number_of_cars" => 5.0,
        "number_of_residences" => 5.0,
        "number_of_residences_with_solar_pv" => 5.0,
        "number_of_inhabitants" => 5.0,
        "percentage_of_old_residences" => 10,
        "building_area" => 24
      }
    }

    it 'spews out attributes of a local dataset' do
      analyzer = DatasetAnalyzer.analyze(dataset, inputs)

      inputs.slice(:number_of_residences, :number_of_cars, :number_of_inhabitants).each do |key, val|
        expect(analyzer[key]).to eq(val)
      end
    end

    describe "has industry -> false" do
      let(:inputs_with_initializers) {
        inputs.merge(
          'has_industry' => false,
          'industry_useful_demand_for_chemical_aggregated_industry' => 5.0
        )
      }

      let(:analyzer) {
        DatasetAnalyzer.analyze(dataset, inputs_with_initializers)
      }

      it 'sets has industry to false' do
        expect(analyzer.fetch(:has_industry)).to eq(false)
      end

      it 'flows through to the end' do
        expect(analyzer.fetch(:init).fetch(:industry_useful_demand_for_chemical_aggregated_industry)).to eq(0.0)
      end
    end

    describe "has industry -> true" do
      let(:inputs_with_initializers) {
        inputs.merge(
          'has_industry' => true,
          'industry_useful_demand_for_chemical_aggregated_industry' => 5.0
        )
      }

      let(:analyzer) {
        DatasetAnalyzer.analyze(dataset, inputs_with_initializers)
      }

      it 'sets has industry to true' do
        expect(analyzer.fetch(:has_industry)).to eq(true)
      end

      it 'flows through to the end' do
        expect(analyzer.fetch(:init).fetch(:industry_useful_demand_for_chemical_aggregated_industry)).to eq(5.0)
      end
    end
  end
end
