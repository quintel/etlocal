require 'rails_helper'

RSpec.describe Amalgamator::Processor::Separate do
  let(:dataset_a) { create(:dataset) }
  let(:dataset_b) { create(:dataset) }
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

  describe 'when separating values for the given datasets' do
    let(:values) do
      [
        # dataset_a,  dataset_b
        [10.0, 30.0],   # values for item 0
        [25.0, 75.0],   # values for item 1
        [20.0, 70.0],  # values for item 2
        [3.5, 10.5],    # values for item 3
      ]
    end

    before do
      allow(dataset_a).to receive(:editable_attributes).and_return(mock_editable_attributes(values, 0))
      allow(dataset_b).to receive(:editable_attributes).and_return(mock_editable_attributes(values, 1))
    end

    it 'separates values according to the combination_method set in each item' do
      items = [
        instance_double(InterfaceItem, item_attrs), # item key 0, combination_method: 'sum' (default)
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[1], nested_combination_method: 'average')),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[2], nested_combination_method: 'min')),
        instance_double(InterfaceItem, item_attrs.merge(key: item_keys[3], nested_combination_method: 'max'))
      ]

      allow(InterfaceElement).to receive(:items).and_return(items)

      result = described_class.perform(dataset_a: dataset_a, dataset_b: dataset_b)

      expect(result).to eq({
        areable_land: 20.0,        # B - A --> 30.0 - 10.0
        analysis_year: 125.0,      # average: B + B - A --> 75.0 + 75.0 - 25.0 = 125.0
        co2_emission_1990: 70.0,   # min of [200, 70] is B --> 70.0
        number_of_buildings: 10.5  # max of [3.5, 10.5] is B --> 10.5
      })
    end

    it 'defaults the combination_method to sum if it is not set on an item' do
      items = [
        instance_double(InterfaceItem, item_attrs.merge(nested_combination_method: nil)),
      ]

      allow(InterfaceElement).to receive(:items).and_return(items)

      result = described_class.perform(dataset_a: dataset_a, dataset_b: dataset_b)

      expect(result).to eq({
        areable_land: 20.0 # 30.0 - 10.0
      })
    end

    it "raises an error for an item with a combination_method we're unfamiliar with" do
      items = [
        instance_double(InterfaceItem, item_attrs.merge(nested_combination_method: 'apples', key: 'areable_land')),
      ]

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect { described_class.perform(dataset_a: dataset_a, dataset_b: dataset_b) }.to raise_error(
        ArgumentError,
        /Unknown combination method 'apples' for InterfaceItem: areable_land/
      )
    end
  end # / when separating values for the given datasets

  describe 'when the method is weighted average' do
    let(:item_attrs) do
      {
        unit: '%',
        flexible: false,
        skip_validation: false,
        nested_combination_method: { 'weighted_average' => ['input_agriculture_final_demand_crude_oil_demand'] },
        default: nil,
        entso: nil
      }
    end

    let(:item_keys) do
      [
        'input_percentage_of_diesel_agriculture_final_demand_crude_oil',
        'input_percentage_of_biodiesel_agriculture_final_demand_crude_oil',
        'input_percentage_of_kerosene_agriculture_final_demand_crude_oil',
        'input_percentage_of_bio_kerosene_agriculture_final_demand_crude_oil',
        'input_percentage_of_lpg_agriculture_final_demand_crude_oil',
        'input_percentage_of_bio_oil_agriculture_final_demand_crude_oil',
        'input_percentage_of_crude_oil_agriculture_final_demand_crude_oil'
      ]
    end

    let(:interface_items) do
      item_keys.map do |key|
        InterfaceItem.new(item_attrs.merge(key: key))
      end
    end

    it 'correctly calculates the reversed weighted average' do
      # Prepare the dataset values
      dataset_values = [
        # Values for dataset_a (index 0)
        {
          'input_agriculture_final_demand_crude_oil_demand' => 100.0,
          'input_percentage_of_diesel_agriculture_final_demand_crude_oil' => 30.0,
          'input_percentage_of_biodiesel_agriculture_final_demand_crude_oil' => 20.0,
          'input_percentage_of_kerosene_agriculture_final_demand_crude_oil' => 10.0,
          'input_percentage_of_bio_kerosene_agriculture_final_demand_crude_oil' => 5.0,
          'input_percentage_of_lpg_agriculture_final_demand_crude_oil' => 1.0,
          'input_percentage_of_bio_oil_agriculture_final_demand_crude_oil' => 5.0,
          'input_percentage_of_crude_oil_agriculture_final_demand_crude_oil' => 0.0
        },
        # Values for dataset_b (index 1)
        {
          'input_agriculture_final_demand_crude_oil_demand' => 200.0,
          'input_percentage_of_diesel_agriculture_final_demand_crude_oil' => 50.0,
          'input_percentage_of_biodiesel_agriculture_final_demand_crude_oil' => 30.0,
          'input_percentage_of_kerosene_agriculture_final_demand_crude_oil' => 100.0,
          'input_percentage_of_bio_kerosene_agriculture_final_demand_crude_oil' => 10.0,
          'input_percentage_of_lpg_agriculture_final_demand_crude_oil' => 5.0,
          'input_percentage_of_bio_oil_agriculture_final_demand_crude_oil' => 5.0,
          'input_percentage_of_crude_oil_agriculture_final_demand_crude_oil' => 5.0
        }
      ]

      # Include the weight key in items
      all_items = interface_items + [InterfaceItem.new(key: 'input_agriculture_final_demand_crude_oil_demand', default: nil, entso: nil)]

      # Prepare datasets
      prepare_datasets(all_items, dataset_values)

      allow(InterfaceElement).to receive(:items).and_return(interface_items)
      allow(EditableAttributesCollection).to receive(:items).and_return(all_items)

      result = described_class.perform(dataset_a: dataset_a, dataset_b: dataset_b)

      # Formula for reversed weighted average:
      # C = (B * B_weight - A * A_weight) / B_weight - A_weight
      expected_results = {
        :input_percentage_of_diesel_agriculture_final_demand_crude_oil=>70.0, # ((200 * 50) - (30 * 100)) / 200 - 100
        :input_percentage_of_biodiesel_agriculture_final_demand_crude_oil=>40.0, # ((200 * 30) - (20 * 100)) / 200 - 100
        :input_percentage_of_kerosene_agriculture_final_demand_crude_oil=>190.0, # ((200 * 100) - (10 * 100)) / 200 - 100
        :input_percentage_of_bio_kerosene_agriculture_final_demand_crude_oil=>15.0, # ((200 * 10) - (5 * 100)) / 200 - 100
        :input_percentage_of_lpg_agriculture_final_demand_crude_oil=>9.0, # ((200 * 5) - (1 * 100)) / 200 - 100
        :input_percentage_of_bio_oil_agriculture_final_demand_crude_oil=>5.0, # ((200 * 5) - (5 * 100)) / 200 - 100
        :input_percentage_of_crude_oil_agriculture_final_demand_crude_oil=>10.0 # ((200 * 5) - (0 * 100)) / 200 - 100
      }
      expect(result).to eq(expected_results)
    end
  end

  private

  def mock_editable_attributes(values, dataset_index, weights = nil)
    attributes = item_keys.each_with_index.map do |key, i|
      instance_double(EditableAttribute, key: key.to_s, value: values[i][dataset_index])
    end

    collection = instance_double(EditableAttributesCollection)

    # Add weights to the attributes if provided
    if weights
      weight_attributes = item_keys.each_with_index.map do |key, i|
        instance_double(EditableAttribute, key: "weight_#{key}", value: weights[i])
      end
      attributes.concat(weight_attributes)
    end

    # Simulate the behavior of `find` method to return the correct attribute for each key
    allow(collection).to receive(:find) do |key|
      attributes.detect { |attr| attr.key == key }
    end

    collection
  end

  def prepare_datasets(items, dataset_values)
    [dataset_a, dataset_b].each_with_index do |dataset, di|
      collection = EditableAttributesCollection.new(dataset)

      # Mock the @attributes instance variable
      attributes = items.map do |item|
        value = dataset_values[di][item.key.to_s]
        EditableAttribute.new(
          dataset,
          item.key.to_s,
          { item.key.to_s => [OpenStruct.new(value: value)] },
          item.default,
          entso_query: item.entso
        )
      end

      # Set the @attributes instance variable
      collection.instance_variable_set(:@attributes, attributes)

      # Assign the mocked collection to the dataset
      dataset.instance_variable_set(:@editable_attributes, collection)
    end
  end

end
