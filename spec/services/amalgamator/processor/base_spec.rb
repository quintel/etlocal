require 'rails_helper'

RSpec.describe Amalgamator::Processor::Base do

  let(:dataset1) { create(:dataset) }
  let(:dataset2) { create(:dataset) }
  let(:dataset3) { create(:dataset) }
  let(:item_keys) { %i[areable_land analysis_year co2_emission_1990 number_of_buildings] }
  let(:item_attrs) do
    {
      key: item_keys[0],
      nested_combination_method: 'sum',
      flexible: false,
      default: nil,
      entso: nil
    }
  end

  describe '#argument_error' do
    it 'raises an ArgumentError with the correct message' do
      expect {
        described_class.send(:argument_error, 'Something went wrong')
      }.to raise_error(ArgumentError, 'Something went wrong. Aborting.')
    end
  end

  describe '#log_error' do
    let(:item) { instance_double(InterfaceItem, key: 'item_key', group: nil) }

    it 'logs an error message with the correct details' do
      expect {
        described_class.send(:log_error, item, 'This is an error message')
      }.to output(/Error for InterfaceItem 'item_key':\nThis is an error message\n/).to_stdout
    end
  end

  describe '#round_item_values' do
    let(:item_values) { { item1: 0.123456789, item2: 0.987654321, item3: nil } }

    it 'rounds values to 8 decimals and replaces nil with 0.0' do
      result = described_class.send(:round_item_values, item_values)
      expect(result).to eq({ item1: 0.12345679, item2: 0.98765432, item3: 0.0 })
    end
  end
end
