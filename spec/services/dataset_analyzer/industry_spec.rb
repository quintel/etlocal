require 'rails_helper'

describe DatasetAnalyzer::Industry do
  let(:dataset)  { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) { DatasetAnalyzer::Industry.new(dataset, nil, edits, {}) }

  describe 'has_industry default' do
    let(:edits) { { } }

    it 'has industry is false' do
      expect(analyzer.has_industry).to be false
    end
  end

  describe "toggling off" do
    let(:edits) { {
      has_industry: false,
      industry_useful_demand_for_chemical_aggregated_industry: 5.0
    } }

    it 'has industry is false' do
      expect(analyzer.has_industry).to be false
    end

    it 'all industry related initializer inputs' do
      expect(analyzer.analyze
        .fetch(:industry_useful_demand_for_chemical_aggregated_industry)).to eq(0)
    end
  end

  describe "toggling on" do
    let(:edits) { {
      has_industry: true,
      industry_useful_demand_for_chemical_aggregated_industry: 5.0
    } }

    it 'has industry is false' do
      expect(analyzer.has_industry).to be true
    end

    describe 'sectors'
  end
end
