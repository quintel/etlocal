require 'rails_helper'

RSpec.describe Amalgamator::Processor::Combine do
  let(:dataset1) { instance_double(Dataset, geo_id: 'NL1', editable_attributes: editable_attrs1) }
  let(:dataset2) { instance_double(Dataset, geo_id: 'NL2', editable_attributes: editable_attrs2) }
  let(:dataset3) { instance_double(Dataset, geo_id: 'NL3', editable_attributes: editable_attrs3) }

  let(:editable_attrs1) { instance_double(EditableAttributesCollection) }
  let(:editable_attrs2) { instance_double(EditableAttributesCollection) }
  let(:editable_attrs3) { instance_double(EditableAttributesCollection) }

  let(:items) do
    [
      instance_double(InterfaceItem, key: :areable_land, nested_combination_method: 'sum', flexible: true, group: nil),
      instance_double(InterfaceItem, key: :analysis_year, nested_combination_method: 'average', flexible: false, group: nil),
      instance_double(InterfaceItem, key: :co2_emission_1990, nested_combination_method: 'min', flexible: false, group: nil),
      instance_double(InterfaceItem, key: :number_of_buildings, nested_combination_method: 'max', flexible: false, group: nil)
    ]
  end

  before do
    allow(InterfaceElement).to receive(:items).and_return(items)
    prepare_datasets
  end

  let(:values) do
    {
      areable_land: [10.0, 20.0, 30.0],
      analysis_year: [25.0, 50.0, 75.0],
      co2_emission_1990: [75.0, 150.0, 225.0],
      number_of_buildings: [3.5, 7.0, 10.5]
    }
  end

  describe 'when combining values' do
    it 'combines values correctly based on combination_method' do
      expect(described_class.perform([dataset1, dataset2, dataset3])).to eq({
        areable_land: 60.0,
        analysis_year: 50.0,
        co2_emission_1990: 75.0,
        number_of_buildings: 10.5
      })
    end
  end

  describe 'handling unknown combination_method' do
    it 'raises an error for unknown combination_method' do
      allow(items.first).to receive(:nested_combination_method).and_return('apples')
      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /Unknown combination_method 'apples' for interface item: areable_land/
      )
    end
  end

  describe 'handling weighted average' do
    it 'calculates weighted averages correctly' do
      allow(items.first).to receive(:nested_combination_method).and_return({ 'weighted_average' => [:areable_land, :analysis_year] })
      result = described_class.perform([dataset1, dataset2, dataset3])
      expect(result[:areable_land]).to eq(25.71428571)
    end

    it 'raises an error for missing weights' do
      allow(items.first).to receive(:nested_combination_method).and_return({ 'weighted_average' => [] })
      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /No weighing keys defined for combination method 'weighted_average' in interface item: areable_land/
      )
    end
  end

  describe 'handling flexible shares' do
    let(:flexible_item) do
      instance_double(InterfaceItem,
        key: :areable_land,
        nested_combination_method: 'sum',
        flexible: true,
        group: nil
      )
    end

    let(:other_item) do
      instance_double(InterfaceItem,
        key: :other_land,
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
        areable_land: [10.0, 20.0, 30.0],
        other_land: [0.2, 0.25, 0.2]
      }
    end

    it "fills out missing shares correctly" do
      expect(described_class.perform([dataset1, dataset2, dataset3])).to eq({
        areable_land: 0.35,
        other_land: 0.65
      })
    end
  end

  private

  def prepare_datasets
    [dataset1, dataset2, dataset3].each_with_index do |dataset, di|
      editable_attrs = [editable_attrs1, editable_attrs2, editable_attrs3][di]

      values.each do |key, value_array|
        allow(editable_attrs).to receive(:find).with(key.to_s).and_return(double(value: value_array[di]))
      end
    end
  end
end
