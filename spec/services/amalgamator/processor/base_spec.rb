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

  # Ensure it raises with the correct formatted message
  describe '#argument_error' do
    it 'raises an ArgumentError with the correct message' do
      expect {
        described_class.send(:argument_error, 'Something went wrong')
      }.to raise_error(ArgumentError, 'Something went wrong. Aborting.')
    end
  end

  # Ensure the output includes item key and message, and handles nil group
  describe '#log_error' do
    let(:item) { instance_double(InterfaceItem, key: 'item_key', group: nil) }

    it 'logs an error message with the correct details' do
      expect {
        described_class.send(:log_error, item, 'This is an error message')
      }.to output(/Error for InterfaceItem 'item_key':\nThis is an error message\n/).to_stdout
    end
  end

  # Rounding to 8 decimals and nil-to-zero conversion
  describe '#round_item_values' do
    let(:values) { { a: 1.123456789, b: nil } }

    it 'rounds values to 8 decimals and replaces nil with 0.0' do
      result = described_class.send(:round_item_values, values.dup)
      expect(result).to eq({ a: 1.12345679, b: 0.0 })
    end
  end

  # Ensures flooring retains total sum and distributes leftovers properly
  describe '#smart_floor' do
    it 'floors values to given precision and distributes remainder based on fractional parts' do
      # Given shares that sum to .334+.333+.333 = 1.0, with precision 2 the raw sum*100 = 100
      # Floored individually: [33,33,33] sum to 99, so one unit is distributed to largest fraction (.334 -> .34)
      shares = [0.334, 0.333, 0.333]
      result = described_class.send(:smart_floor, shares, precision: 2)
      expect(result).to eq([0.34, 0.33, 0.33])
    end

    it 'returns exact floors when no remainder remains' do
      # Equal shares that perfectly floor without leftover
      shares = [0.333, 0.333, 0.333]
      result = described_class.send(:smart_floor, shares, precision: 2)
      expect(result).to eq([0.33, 0.33, 0.33])
    end

    it 'rounds based on index when two shares could be adjusted' do
      # In this case, the 'first' share is picked to get the excess
      shares = [0.335, 0.335, 0.330]
      result = described_class.send(:smart_floor, shares, precision: 2)
      expect(result).to eq([0.34, 0.33, 0.33])
    end
  end

  # Calculates the flexible item so total equals 1.0
  describe '#adjust_flexible_shares' do
    let(:element) { instance_double(InterfaceElement, key: 'elem_key') }
    # Define a fixed and a flexible item, both belonging to the same group
    let(:item_fixed) { instance_double('InterfaceItem', key: :a, flexible: false) }
    let(:item_flex)  { instance_double('InterfaceItem', key: :b, flexible: true) }
    let(:group) do
      instance_double(
        'InterfaceGroup',
        items: [item_fixed, item_flex],
        header: 'TestGroup',
        element: element
      )
    end

    before do
      # Stub group associations and the global InterfaceElement.items lookup
      allow(item_fixed).to receive(:group).and_return(group)
      allow(item_flex).to receive(:group).and_return(group)
      allow(InterfaceElement).to receive(:items).and_return([item_fixed, item_flex])
    end

    it 'adjusts the flexible share so that total equals 1.0' do
      # When one item has no value (nil), flexible share fills to ensure sum == 1.0
      dataset_c_values = { a: 0.33333333, b: nil }
      result = described_class.send(:adjust_flexible_shares, dataset_c_values.dup)
      total = result.values.inject(&:+)
      expect(total.round(8)).to eq(1.0)
    end

    context 'when multiple flexible items exist in a group' do
      before do
        # Mark both items as flexible
        allow(item_fixed).to receive(:flexible).and_return(true)
        allow(described_class).to receive(:log_error)
      end

      it 'logs an error and does not change the values' do
        # The presence of two flexible items should trigger log_error and leave values unchanged
        values = { a: 0.5, b: 0.5 }
        result = described_class.send(:adjust_flexible_shares, values.dup)
        expect(described_class).to have_received(:log_error).with(
          item_fixed,
          "Multiple flexible shares in TestGroup"
        )
        expect(result).to eq(values)
      end
    end
  end
end
