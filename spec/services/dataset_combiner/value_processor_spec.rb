require 'rails_helper'

RSpec.describe DatasetCombiner::ValueProcessor do

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

  describe 'when combining values for the given datasets' do
    let(:values) do
      [
        # dataset1, dataset2, dataset3
        [     10.0,     20.0,     30.0], # values for item 0
        [     25.0,     50.0,     75.0], # values for item 1
        [     75.0,    150.0,    225.0], # values for item 2
        [      3.5,      7.0,     10.5], # values for item 3
      ]
    end

    it 'combines values according to the combination_method set in each item' do
      items = [
        instance_double(InterfaceItem, item_attrs), # item key 0, combination_method: 'sum' (which is default)
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[1], nested_combination_method: 'average')),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[2], nested_combination_method: 'min')),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[3], nested_combination_method: 'max'))
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        "#{item_keys[0]}": 60.0, # sum of [10.0,  20.0,  30.0]
        "#{item_keys[1]}": 50.0, # avg of [25.0,  50.0,  75.0]
        "#{item_keys[2]}": 75.0, # min of [75.0, 150.0, 225.0]
        "#{item_keys[3]}": 10.5  # max of [ 3.5,   7.0,  10.5]
      })
    end

    it 'defaults the combination_method to sum if it is not set on an item' do
      items = [
        instance_double(InterfaceItem, item_attrs.merge(nested_combination_method: nil)),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        "#{item_keys[0]}": 60.0 # sum of [10.0,  20.0,  30.0]
      })
    end

    it "raises an error for an item with a combination_method we're unfamiliar with" do
      items = [
        instance_double(InterfaceItem, item_attrs.merge(nested_combination_method: 'apples')),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /Don't know how to deal with combination_method '#{items[0].nested_combination_method}' in interface item:\n#{items[0].key}/
      )
    end


  end # / when combining values for the given datasets

  describe 'when calculating weighted_averages' do

    let(:values) do
      [
        # dataset1, dataset2, dataset3
        [     10.0,     20.0,     30.0], # values for item 0
        [     25.0,     50.0,     75.0], # values for item 1
        [     75.0,    150.0,    225.0], # values for item 2
        [      3.5,      7.0,     10.5], # values for item 3
      ]
    end

    it 'correctly uses the set items as weights' do items = [
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[0], nested_combination_method: { 'weighted_average' => [item_keys[0], item_keys[1]] })),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[1], nested_combination_method: { 'weighted_average' => [item_keys[0], item_keys[1]] })),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[2], nested_combination_method: { 'weighted_average' => [item_keys[0], item_keys[1]] })),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[3], nested_combination_method: { 'weighted_average' => [item_keys[0], item_keys[1]] }))
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        "#{item_keys[0]}": 25.71428571,  # weighted avg of [10.0,  20.0,  30.0]
        "#{item_keys[1]}": 64.28571429,  # weighted avg of [25.0,  50.0,  75.0]
        "#{item_keys[2]}": 192.85714286, # weighted avg of [75.0, 150.0, 225.0]
        "#{item_keys[3]}": 9.0           # weighted avg of [ 3.5,   7.0,  10.5]
      })
    end

    it 'raises an error when no items have been set as weights (e.g. weighted_average is empty)' do
      items = [
        instance_double(InterfaceItem, item_attrs.merge(nested_combination_method: { 'weighted_average' => [] }))
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /No weighing keys defined for combination method 'weighted average' in interface item:\n#{items[0].key}/
      )
    end

  end # / when calculating weighted_averages

  describe 'when determining flexible shares' do

    let(:values) do
      [
        # dataset1, dataset2, dataset3
        [      0.0,     0.00,     0.0], # values for item 0, the flexible one
        [      0.1,     0.40,     0.7], # values for item 1
        [      0.4,     0.35,     0.0], # values for item 2
      ]
    end

    it "fills out any 'share space' left in an item's group" do
      # For this test we grab actual, existing InterfaceItems from an existing group.
      items = [
        InterfaceItem.find(:input_energy_cokesoven_transformation_loss_output_conversion), # This one is flexible
        InterfaceItem.find(:input_energy_cokesoven_transformation_cokes_output_conversion),
        InterfaceItem.find(:input_energy_cokesoven_transformation_coal_gas_output_conversion)
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        input_energy_cokesoven_transformation_loss_output_conversion: 0.35,
        input_energy_cokesoven_transformation_cokes_output_conversion: 0.4,
        input_energy_cokesoven_transformation_coal_gas_output_conversion: 0.25
      })
    end

    it 'raises an error if more than one item per group is defined as flexible' do
      items = [
        InterfaceItem.find(:input_energy_cokesoven_transformation_loss_output_conversion), # This one is flexible
        InterfaceItem.find(:input_energy_cokesoven_transformation_cokes_output_conversion),
        InterfaceItem.find(:input_energy_cokesoven_transformation_coal_gas_output_conversion)
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)
      allow_any_instance_of(InterfaceItem).to receive(:flexible).and_return(true)

      expect { described_class.perform([dataset1, dataset2, dataset3]) }.to raise_error(
        ArgumentError,
        /More than one flexible InterfaceItems found in InterfaceGroup #{items[0].group.header}/
      )
    end

  end

  private

  # This method creates an EditableAttributesCollection with EditableAttributes
  # containing the values set in :values and adds these to the datasets.
  # An OpenStruct is used to stub/mock the Commits and DatasetEdits in one go.
  def prepare_datasets(items, edit_values = values)
    [dataset1, dataset2, dataset3].each_with_index do |dataset, di|
      collection = EditableAttributesCollection.new(dataset)

      collection.instance_variable_set(
        :@attributes,
        items.map.with_index do |item, ii|
          EditableAttribute.new(
            dataset,
            item.key.to_s,
            { item.key.to_s => [OpenStruct.new(value: edit_values[ii][di])] } # Ugly :(
          )
        end
      )

      dataset.instance_variable_set(:@editable_attributes, collection)
    end
  end

end
