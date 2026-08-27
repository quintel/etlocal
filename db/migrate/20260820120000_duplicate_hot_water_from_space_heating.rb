class DuplicateHotWaterFromSpaceHeating < ActiveRecord::Migration[8.1]
  # Space heating technology shares used to serve double duty as the hot water
  # technology shares. Now that hot water has its own keys, seed them with the
  # space heating values so nothing changes for existing datasets.
  #
  # space heating key => hot water key
  KEYS = {
    'households_final_demand_for_space_heating_electricity_households_space_heater_electricity_parent_share' =>
      'households_final_demand_for_hot_water_electricity_households_water_heater_resistive_electricity_parent_share',
    'households_final_demand_for_space_heating_electricity_households_space_heater_heatpump_air_water_electricity_parent_share' =>
      'households_final_demand_for_hot_water_electricity_households_water_heater_heatpump_air_water_electricity_parent_share',
    'households_final_demand_for_space_heating_electricity_households_space_heater_hybrid_heatpump_air_water_electricity_parent_share' =>
      'households_final_demand_for_hot_water_electricity_households_water_heater_hybrid_heatpump_air_water_electricity_parent_share',
    'households_final_demand_for_space_heating_electricity_households_space_heater_heatpump_ground_water_electricity_parent_share' =>
      'households_final_demand_for_hot_water_electricity_households_water_heater_heatpump_ground_water_electricity_parent_share',
    'households_final_demand_for_space_heating_network_gas_households_space_heater_combined_network_gas_parent_share' =>
      'households_final_demand_for_hot_water_network_gas_households_water_heater_combined_network_gas_parent_share',
    'households_final_demand_for_space_heating_network_gas_households_space_heater_network_gas_parent_share' =>
      'households_final_demand_for_hot_water_network_gas_households_water_heater_network_gas_parent_share',
    'households_final_demand_for_space_heating_network_gas_households_space_heater_hybrid_heatpump_air_water_electricity_parent_share' =>
      'households_final_demand_for_hot_water_network_gas_households_water_heater_hybrid_heatpump_air_water_electricity_parent_share'
  }.freeze

  MESSAGE = 'Duplicate space heating technology split values for hot water technology split'.freeze

  def up
    say "Checking and migrating #{Dataset.count} datasets"

    dataset_ids = []

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{dataset_ids.length} updated)"
      end

      values = hot_water_values(dataset)
      next if values.empty?

      ActiveRecord::Base.transaction do
        commit = Commit.create!(
          user: User.robot,
          dataset: dataset,
          message: MESSAGE
        )

        create_edits(commit.id, values)
      end

      dataset_ids.push(dataset.id)
    end

    puts
    puts "Updated #{dataset_ids.length} datasets with the following IDs:"
    puts "  #{dataset_ids.join(',')}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  # Internal: The hot water keys and their values, copied from the dataset's space heating
  # values. Keys whose space heating counterpart has no value are omitted.
  #
  # Returns an array of [key, value] pairs.
  def hot_water_values(dataset)
    editable = dataset.editable_attributes

    KEYS.filter_map do |space_heating_key, hot_water_key|
      value = editable.find(space_heating_key)&.value
      next if value.nil?

      [hot_water_key, value]
    end
  end

  def create_edits(commit_id, values)
    values.each do |key, value|
      DatasetEdit.create!(
        commit_id: commit_id,
        key: key,
        value: value
      )
    end
  end
end
