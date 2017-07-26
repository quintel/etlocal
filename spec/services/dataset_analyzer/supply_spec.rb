require 'rails_helper'

describe DatasetAnalyzer::Supply do
  let(:dataset)  { Atlas::Dataset::Derived.find(:ameland) }
  let(:analyzer) { DatasetAnalyzer::Supply.new(dataset, nil, edits, {}) }

  describe "analyzes supply related inputs" do
    let(:edits) { {
      'number_of_energy_heater_for_heat_network_network_gas' => 500
    } }

    it 'analyzes' do
      expect(analyzer.analyze).to eq({
        'number_of_energy_heater_for_heat_network_network_gas' => 500
      })
    end
  end
end
