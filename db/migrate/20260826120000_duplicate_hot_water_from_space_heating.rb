class DuplicateHotWaterFromSpaceHeating < ActiveRecord::Migration[7.0]
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
    datasets = []

    Dataset.find_each do |dataset|
      print "Updating #{dataset.geo_id}... "

      attributes = dataset.editable_attributes

      values = KEYS.filter_map do |space_heating_key, hot_water_key|
        value = attributes.find(space_heating_key)&.value
        next if value.nil?

        [hot_water_key, value]
      end

      if values.empty?
        puts 'nothing to change!'
        next
      end

      ActiveRecord::Base.transaction do
        commit = Commit.create!(
          user: User.robot,
          dataset: dataset,
          message: MESSAGE
        )

        values.each do |key, value|
          FloatDatasetEdit.create!(commit: commit, key: key, value: value)
        end
      end

      datasets.push(dataset)
      puts "done! (#{values.length} keys)"
    end

    puts
    puts "Updated #{datasets.length} datasets with the following IDs:"
    puts "  #{datasets.map(&:id).join(',')}"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
