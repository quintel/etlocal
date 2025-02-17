require 'rails_helper'

RSpec.describe Amalgamator::Processor::Separate do
  let(:target_dataset) { instance_double(Dataset, geo_id: 'NL1', editable_attributes: target_attrs) }
  let(:subtracted_dataset) { instance_double(Dataset, geo_id: 'NL2', editable_attributes: subtracted_attrs) }

  let(:target_attrs) { instance_double(EditableAttributesCollection) }
  let(:subtracted_attrs) { instance_double(EditableAttributesCollection) }

  let(:items) do
    [
      instance_double(InterfaceItem, key: :number_of_cars, nested_combination_method: 'sum', flexible: false, group: nil),
      instance_double(InterfaceItem, key: :co2_emission_1990, nested_combination_method: 'average', flexible: false, group: nil),
      instance_double(InterfaceItem, key: :interconnector_capacity, nested_combination_method: 'min', flexible: false, group: nil)
    ]
  end

  before do
    allow(InterfaceElement).to receive(:items).and_return(items)
    prepare_datasets
  end

  let(:values) do
    {
      number_of_cars: [10.0, 3.0],
      co2_emission_1990: [500.0, 200.0],
      interconnector_capacity: [50.0, 30.0]
    }
  end

  describe 'when subtracting datasets' do
    it 'correctly subtracts dataset values based on combination_method' do
      expect(described_class.perform(target_dataset, subtracted_dataset)).to eq({
        number_of_cars: 7.0,  # 10 - 3 = 7
        co2_emission_1990: 800.0,  # 500 + (500 - 200) = 800 (average calculation)
        interconnector_capacity: 50.0 # min takes B’s value
      })
    end
  end

  describe 'handling unknown combination_method' do
    it 'raises an error for unknown combination_method' do
      allow(items.first).to receive(:nested_combination_method).and_return('unknown_method')
      expect { described_class.perform(target_dataset, subtracted_dataset) }.to raise_error(
        ArgumentError,
        /Unknown combination method 'unknown_method' for InterfaceItem: number_of_cars/
      )
    end
  end

  describe 'handling weighted average' do
    it 'calculates weighted averages correctly' do
      allow(items.first).to receive(:nested_combination_method).and_return({ 'weighted_average' => [:number_of_cars, :co2_emission_1990] })
      result = described_class.perform(target_dataset, subtracted_dataset)
      expect(result[:number_of_cars]).to be_within(0.01).of(14.65)
    end
  end

  describe 'handling flexible shares' do
    let(:flexible_item) do
      instance_double(InterfaceItem,
        key: :number_of_cars,
        nested_combination_method: 'sum',
        flexible: true,
        group: nil
      )
    end

    let(:other_item) do
      instance_double(InterfaceItem,
        key: :interconnector_capacity,
        nested_combination_method: 'sum',
        flexible: false,
        group: nil
      )
    end

    let(:group) do
      instance_double(InterfaceGroup,
        header: 'Test Group',
        items: [flexible_item, other_item],
        present?: true
      )
    end

    before do
      allow(flexible_item).to receive(:group).and_return(group)
      allow(other_item).to receive(:group).and_return(group)
    end

    let(:items) { [flexible_item, other_item] }

    let(:values) do
      {
        number_of_cars: [0.3, 0.2],
        interconnector_capacity: [0.3, 0.1]
      }
    end

    it "adjusts flexible shares correctly" do
      puts "\nBefore processing:"
      puts "Target dataset values: #{values.transform_values { |v| v[0] }}"
      puts "Subtracted dataset values: #{values.transform_values { |v| v[1] }}"

      result = described_class.perform(target_dataset, subtracted_dataset)

      puts "\nAfter processing:"
      puts "Result: #{result}"
      puts "Flexible item (#{flexible_item.key}): #{result[flexible_item.key]}"
      puts "Other item (#{other_item.key}): #{result[other_item.key]}"
      puts "Group total: #{result.values.sum}"

      expect(result).to eq({
        number_of_cars: 0.8,
        interconnector_capacity: 0.2
      })
    end
  end

  private

  def prepare_datasets
    [target_dataset, subtracted_dataset].each_with_index do |dataset, di|
      editable_attrs = [target_attrs, subtracted_attrs][di]

      values.each do |key, value_array|
        allow(editable_attrs).to receive(:find).with(key.to_s).and_return(double(value: value_array[di]))
      end
    end
  end
end
