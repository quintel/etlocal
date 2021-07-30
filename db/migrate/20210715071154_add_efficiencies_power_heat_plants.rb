class AddEfficienciesPowerHeatPlants < ActiveRecord::Migration[5.2]
  EFFICIENCIES = {
    'input_energy_power_supercritical_coal_electricity_output_conversion' => 36,
    'input_energy_power_ultra_supercritical_coal_electricity_output_conversion' => 46,
    'input_energy_power_ultra_supercritical_ccs_coal_electricity_output_conversion' => 36.1,
    'input_energy_power_ultra_supercritical_cofiring_coal_electricity_output_conversion' => 42,
    'input_energy_power_combined_cycle_coal_electricity_output_conversion' => 45.3,
    'input_energy_power_combined_cycle_ccs_coal_electricity_output_conversion' => 37.3,
    'input_energy_power_ultra_supercritical_lignite_electricity_output_conversion' => 40,
    'input_energy_power_ultra_supercritical_oxyfuel_ccs_lignite_electricity_output_conversion' => 30.5,
    'input_energy_power_turbine_network_gas_electricity_output_conversion' => 34,
    'input_energy_power_combined_cycle_network_gas_electricity_output_conversion' => 60,
    'input_energy_power_combined_cycle_ccs_network_gas_electricity_output_conversion' => 49,
    'input_energy_power_ultra_supercritical_network_gas_electricity_output_conversion' => 40,
    'input_energy_power_ultra_supercritical_crude_oil_electricity_output_conversion' => 45,
    'input_energy_power_engine_diesel_electricity_output_conversion' => 38,
    'input_energy_power_engine_network_gas_electricity_output_conversion' => 48,
    'input_energy_power_supercritical_waste_mix_electricity_output_conversion' => 25,
    'input_energy_power_nuclear_gen2_uranium_oxide_electricity_output_conversion' => 32,
    'input_energy_power_nuclear_gen3_uranium_oxide_electricity_output_conversion' => 36,
    'input_energy_chp_local_engine_network_gas_electricity_output_conversion' => 43,
    'input_energy_chp_local_engine_biogas_electricity_output_conversion' => 43,
    'input_energy_chp_local_wood_pellets_electricity_output_conversion' => 28.9,
    'input_energy_chp_combined_cycle_network_gas_electricity_output_conversion' => 46,
    'input_energy_chp_ultra_supercritical_cofiring_coal_electricity_output_conversion' => 37,
    'input_energy_chp_ultra_supercritical_coal_electricity_output_conversion' => 40,
    'input_energy_chp_ultra_supercritical_lignite_electricity_output_conversion' => 35,
    'input_energy_chp_supercritical_waste_mix_electricity_output_conversion' => 27,
    'input_industry_chp_turbine_gas_power_fuelmix_electricity_output_conversion' => 38,
    'input_industry_chp_engine_gas_power_fuelmix_electricity_output_conversion' => 42,
    'input_industry_chp_combined_cycle_gas_power_fuelmix_electricity_output_conversion' => 46,
    'input_industry_chp_ultra_supercritical_coal_electricity_output_conversion' => 40,
    'input_industry_chp_wood_pellets_electricity_output_conversion' => 27.9,
    'input_energy_chp_local_engine_network_gas_steam_hot_water_output_conversion' => 47,
    'input_energy_chp_local_engine_biogas_steam_hot_water_output_conversion' => 47,
    'input_energy_chp_local_wood_pellets_steam_hot_water_output_conversion' => 82.1,
    'input_energy_chp_combined_cycle_network_gas_steam_hot_water_output_conversion' => 42,
    'input_energy_chp_ultra_supercritical_cofiring_coal_steam_hot_water_output_conversion' => 15,
    'input_energy_chp_ultra_supercritical_coal_steam_hot_water_output_conversion' => 15,
    'input_energy_chp_ultra_supercritical_lignite_steam_hot_water_output_conversion' => 15,
    'input_energy_chp_supercritical_waste_mix_steam_hot_water_output_conversion' => 15,
    'input_industry_chp_turbine_gas_power_fuelmix_steam_hot_water_output_conversion' => 42,
    'input_industry_chp_engine_gas_power_fuelmix_steam_hot_water_output_conversion' => 48,
    'input_industry_chp_combined_cycle_gas_power_fuelmix_steam_hot_water_output_conversion' => 42,
    'input_industry_chp_ultra_supercritical_coal_steam_hot_water_output_conversion' => 15,
    'input_industry_chp_wood_pellets_steam_hot_water_output_conversion' => 83.5,
    'input_energy_heat_burner_wood_pellets_steam_hot_water_output_conversion' => 90,
    'input_energy_heat_burner_coal_steam_hot_water_output_conversion' => 72,
    'input_energy_heat_burner_hydrogen_steam_hot_water_output_conversion' => 110,
    'input_energy_heat_burner_crude_oil_steam_hot_water_output_conversion' => 72,
    'input_energy_heat_burner_network_gas_steam_hot_water_output_conversion' => 103,
    'input_energy_heat_burner_waste_mix_steam_hot_water_output_conversion' => 105,
    'input_energy_heat_heatpump_water_water_electricity_steam_hot_water_output_conversion' => 100,
    'input_industry_heat_burner_lignite_steam_hot_water_output_conversion' => 72,
    'input_industry_heat_burner_coal_steam_hot_water_output_conversion' => 72,
    'input_industry_heat_burner_crude_oil_steam_hot_water_output_conversion' => 72
  }.freeze

  def self.up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Efficiency researched by Quintel. Source data can be found below the slider of this plant in the ETM front-end'
          )

          EFFICIENCIES.each do |key, value|
            create_edit(com, key, value)
          end
        end

      changed += 1
    end
    say "Finished (#{changed} updated)"
  end

  private

  # Create a new dataset edit
  def create_edit(commit, key, value)
    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: key,
        value: value
      )
    end
  end
end
