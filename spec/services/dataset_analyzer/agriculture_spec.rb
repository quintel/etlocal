require 'rails_helper'

describe DatasetAnalyzer::Agriculture do
  let(:dataset)  { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) { DatasetAnalyzer::Agriculture.new(dataset, edits, {}) }

  describe 'has_agriculture default' do
    let(:edits) { { } }

    it 'has industry is false' do
      expect(analyzer.has_agriculture).to be false
    end
  end

  describe "toggling off" do
    let(:edits) { {
      has_agriculture: false,
      agriculture_useful_demand_electricity: 5.0
    } }

    it 'has industry is false' do
      expect(analyzer.has_agriculture).to be false
    end

    it 'all industry related initializer inputs' do
      expect(analyzer.analyze
        .fetch(:agriculture_useful_demand_electricity)).to eq(0)
    end
  end

  describe "toggling on" do
    let(:edits) { {
      has_agriculture: true,
      agriculture_useful_demand_electricity: 5.0
    } }

    it 'has industry is false' do
      expect(analyzer.has_agriculture).to be true
    end

    describe 'sectors'
  end
end
