require 'rails_helper'

RSpec.describe DatasetCombiner::ValueProcessor do

  let(:dataset1) { create(:dataset) }
  let(:dataset2) { create(:dataset) }
  let(:dataset3) { create(:dataset) }
  let(:values) do
    [
      # dataset1, dataset2, dataset3
      [     10.0,     20.0,     30.0], # values for item 0
      [     25.0,     50.0,     75.0], # values for item 1
      [     75.0,    150.0,    225.0], # values for item 2
      [      3.5,      7.0,     10.5], # values for item 3
    ]
  end

  describe 'when combining values for the given datasets' do

    it 'combines values according to the combination_method set in each item' do
      items = [
        instance_double(InterfaceItem, key: :agriculture_final_demand_network_gas_demand, combination_method: 'sum', flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :annual_infrastructure_cost_gas, combination_method: 'average', flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :households_final_demand_solar_thermal_demand, combination_method: 'min', flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :energy_distribution_greengas_demand, combination_method: 'max', flexible: false, default: nil, entso: nil),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        agriculture_final_demand_network_gas_demand: 60.0,  # sum of [10.0,  20.0,  30.0]
        annual_infrastructure_cost_gas: 50.0,               # avg of [25.0,  50.0,  75.0]
        households_final_demand_solar_thermal_demand: 75.0, # min of [75.0, 150.0, 225.0]
        energy_distribution_greengas_demand: 10.5           # max of [ 3.5,   7.0,  10.5]
      })
    end

    it 'defaults the combination_method to sum if it is not set on an item' do
      items = [
        instance_double(InterfaceItem, key: :agriculture_final_demand_network_gas_demand, combination_method: nil, flexible: false, default: nil, entso: nil),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1])
      ).to eq({
        agriculture_final_demand_network_gas_demand: 60.0  # sum of [10.0,  20.0,  30.0]
      })
    end

    it 'correctly calculates values for items with combination_method "weighted_averages"' do
      items = [
        instance_double(InterfaceItem, key: :agriculture_final_demand_network_gas_demand, combination_method: { weighted_average: [:agriculture_final_demand_network_gas_demand, :annual_infrastructure_cost_gas] }, flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :annual_infrastructure_cost_gas, combination_method: { weighted_average: [:agriculture_final_demand_network_gas_demand, :annual_infrastructure_cost_gas] }, flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :households_final_demand_solar_thermal_demand, combination_method: { weighted_average: [:agriculture_final_demand_network_gas_demand, :annual_infrastructure_cost_gas] }, flexible: false, default: nil, entso: nil),
        instance_double(InterfaceItem, key: :energy_distribution_greengas_demand, combination_method: { weighted_average: [:agriculture_final_demand_network_gas_demand, :annual_infrastructure_cost_gas] }, flexible: false, default: nil, entso: nil),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect(
        described_class.perform([dataset1, dataset2, dataset3])
      ).to eq({
        agriculture_final_demand_network_gas_demand: 25.714286,   # weighted avg of [10.0,  20.0,  30.0]
        annual_infrastructure_cost_gas: 64.285714,                # weighted avg of [25.0,  50.0,  75.0]
        households_final_demand_solar_thermal_demand: 192.857143, # weighted avg of [75.0, 150.0, 225.0]
        energy_distribution_greengas_demand: 9.0                  # weighted avg of [ 3.5,   7.0,  10.5]
      })
    end

    it "raises an error for an item with a combination_method we're unfamiliar with" do
      items = [
        instance_double(InterfaceItem, key: :agriculture_final_demand_network_gas_demand, combination_method: 'apples', flexible: false, default: nil, entso: nil),
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /Error! Don't know how to deal with combination_method '#{items[0].combination_method}', set in item #{items[0].key}/
      )
    end

    it 'raises an error for an item with combination_method "weighted_average" without keys' do
      items = [
        instance_double(InterfaceItem, key: :number_of_inhabitants, combination_method: { weighted_average: [] }, flexible: false, default: nil, entso: nil)
      ]

      prepare_datasets(items)

      allow(InterfaceElement).to receive(:items).and_return(items)

      expect { described_class.perform([dataset1]) }.to raise_error(
        ArgumentError,
        /Error! No weighing keys defined for combination method 'weighted average' in item #{items[0].key}/
      )
    end

  end

  private

  # This method creates an EditableAttributesCollection with EditableAttributes
  # containing the values set in :values and adds these to the datasets.
  # An OpenStruct is used to stub/mock the Commits and DatasetEdits in one go.
  def prepare_datasets(items)
    [dataset1, dataset2, dataset3].each_with_index do |dataset, di|
      collection = EditableAttributesCollection.new(dataset)

      collection.instance_variable_set(
        :@attributes,
        items.map.with_index do |item, ii|
          EditableAttribute.new(
            dataset,
            item.key.to_s,
            { item.key.to_s => [OpenStruct.new(value: values[ii][di])] }
          )
        end
      )

      dataset.instance_variable_set(:@editable_attributes, collection)
    end
  end

end
