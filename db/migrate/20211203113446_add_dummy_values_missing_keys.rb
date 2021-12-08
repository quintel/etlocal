class AddDummyValuesMissingKeys < ActiveRecord::Migration[5.2]
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
    'input_industry_heat_burner_crude_oil_steam_hot_water_output_conversion' => 72,
    'energy_power_combined_cycle_network_gas_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_network_gas_full_load_hours' => 0.0,
    'energy_power_turbine_network_gas_full_load_hours' => 0.0,
    'energy_power_engine_network_gas_full_load_hours' => 0.0,
    'energy_power_supercritical_coal_full_load_hours' => 0.0,
    'energy_power_combined_cycle_coal_gas_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_ccs_coal_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_coal_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_cofiring_coal_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_lignite_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_oxyfuel_ccs_lignite_full_load_hours' => 0.0,
    'energy_power_engine_diesel_full_load_hours' => 0.0,
    'energy_power_ultra_supercritical_crude_oil_full_load_hours' => 0.0,
    'energy_power_nuclear_gen2_uranium_oxide_full_load_hours' => 0.0,
    'energy_power_nuclear_gen3_uranium_oxide_full_load_hours' => 0.0,
    'energy_power_geothermal_full_load_hours' => 0.0,
    'energy_power_hydro_mountain_full_load_hours' => 0.0,
    'energy_power_hydro_river_full_load_hours' => 0.0,
    'energy_power_supercritical_waste_mix_full_load_hours' => 0.0,
    'energy_power_supercritical_ccs_waste_mix_full_load_hours' => 0.0,
    'energy_chp_coal_gas_full_load_hours' => 0.0,
    'industry_chp_turbine_gas_power_fuelmix_full_load_hours' => 0.0,
    'industry_chp_engine_gas_power_fuelmix_full_load_hours' => 0.0,
    'industry_chp_combined_cycle_gas_power_fuelmix_full_load_hours' => 0.0,
    'energy_chp_local_engine_network_gas_full_load_hours' => 0.0,
    'energy_chp_combined_cycle_network_gas_full_load_hours' => 0.0,
    'energy_chp_ultra_supercritical_cofiring_coal_full_load_hours' => 0.0,
    'energy_chp_ultra_supercritical_coal_full_load_hours' => 0.0,
    'energy_chp_ultra_supercritical_lignite_full_load_hours' => 0.0,
    'industry_chp_ultra_supercritical_coal_full_load_hours' => 0.0,
    'energy_chp_local_engine_biogas_full_load_hours' => 0.0,
    'energy_chp_local_wood_pellets_full_load_hours' => 0.0,
    'industry_chp_wood_pellets_full_load_hours' => 0.0,
    'energy_chp_supercritical_waste_mix_full_load_hours' => 0.0,
    'energy_heat_burner_wood_pellets_full_load_hours' => 0.0,
    'input_energy_power_ultra_supercritical_ccs_coal_production' => 0.0,
    'input_energy_chp_ultra_supercritical_coal_production' => 0.0,
    'input_energy_chp_ultra_supercritical_cofiring_coal_production' => 0.0,
    'input_energy_power_supercritical_ccs_waste_mix_production' => 0.0,
    'input_energy_chp_combined_cycle_network_gas_production' => 0.0,
    'input_energy_chp_local_engine_network_gas_production' => 0.0,
    'input_energy_power_engine_diesel_production' => 0.0,
    'input_energy_power_wind_turbine_inland_production' => 0.0,
    'input_energy_power_wind_turbine_coastal_production' => 0.0,
    'input_energy_power_wind_turbine_offshore_production' => 0.0,
    'input_energy_power_solar_pv_solar_radiation_production' => 0.0,
    'input_energy_power_solar_csp_solar_radiation_production' => 0.0,
    'input_energy_power_supercritical_waste_mix_production' => 0.0,
    'input_energy_chp_supercritical_waste_mix_production' => 0.0,
    'input_energy_chp_local_wood_pellets_production' => 0.0,
    'input_energy_chp_local_engine_biogas_production' => 0.0,
    'input_energy_power_hydro_river_production' => 0.0,
    'input_energy_power_hydro_mountain_production' => 0.0,
    'input_energy_power_geothermal_production' => 0.0,
    'input_energy_heat_burner_hydrogen_production' => 0.0,
    'energy_extraction_uranium_oxide_demand' => 0.0,
    'input_households_solar_pv_demand' => 0.0,
    'input_buildings_solar_pv_demand' => 0.0,
    'input_transport_road_human_powered_bicycle_demand' => 0.0,
    'transport_final_demand_for_road_compressed_network_gas_demand' => 0.0,
    'transport_final_demand_hydrogen_demand' => 0.0,
    'transport_final_demand_for_road_lng_demand' => 0.0,
    'transport_final_demand_for_road_bio_lng_demand' => 0.0,
    'agriculture_final_demand_hydrogen_demand' => 0.0,
    'input_industry_chemical_fertilizers_hydrogen_non_energetic_demand' => 0.0,
    'input_industry_ict_electricity_demand' => 0.0,
    'input_industry_other_network_gas_non_energetic_demand' => 0.0,
    'input_industry_other_wood_pellets_non_energetic_demand' => 0.0,
    'input_industry_other_crude_oil_non_energetic_demand' => 0.0,
    'input_industry_other_coal_non_energetic_demand' => 0.0,
    'input_industry_other_cokes_non_energetic_demand' => 0.0,
    'industry_chp_combined_cycle_gas_power_fuelmix_demand' => 0.0,
    'industry_chp_engine_gas_power_fuelmix_demand' => 0.0,
    'industry_chp_turbine_gas_power_fuelmix_demand' => 0.0,
    'industry_chp_ultra_supercritical_coal_demand' => 0.0,
    'industry_chp_wood_pellets_demand' => 0.0,
    'industry_heat_burner_lignite_demand' => 0.0,
    'industry_heat_burner_coal_demand' => 0.0,
    'industry_heat_well_geothermal_demand' => 0.0,
    'industry_heat_burner_crude_oil_demand' => 0.0,
    'buildings_roof_surface_available_for_pv' => 281,
    'residences_roof_surface_available_for_pv' => 561,
    'input_share_mixer_gas_fuel_bio_oil' => 0.3,
    'input_share_mixer_gas_fuel_network_gas' => 0.5,
    'input_share_mixer_gas_fuel_oil' => 0.2
  }.freeze

  def self.up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.where(geo_id: ['SK','AT','BE','BG','CY','CZ','DE','DK','EE','EE','FI','FR','UK','EL','HR','HU','IE','IR','IT','LT','LU','LV','NL','PL','PT','RO','SE','SI']).each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No sufficient European source found.'
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
