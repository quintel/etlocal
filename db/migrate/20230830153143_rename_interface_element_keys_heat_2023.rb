class RenameInterfaceElementKeysHeat2023 < ActiveRecord::Migration[5.0]

  # old_key => new_key
  KEYS = {
    # production
    'input_energy_chp_ultra_supercritical_coal_production' => 'input_energy_chp_ultra_supercritical_ht_coal_production',
    'input_energy_chp_ultra_supercritical_cofiring_coal_production' => 'input_energy_chp_ultra_supercritical_cofiring_ht_coal_production',
    'input_energy_chp_ultra_supercritical_lignite_production' => 'input_energy_chp_ultra_supercritical_ht_lignite_production',
    'input_energy_chp_combined_cycle_network_gas_production' => 'input_energy_chp_combined_cycle_ht_network_gas_production',
    'input_energy_chp_local_engine_network_gas_production' => 'input_energy_chp_local_engine_ht_network_gas_production',
    'input_energy_chp_supercritical_waste_mix_production' => 'input_energy_chp_supercritical_ht_waste_mix_production',
    'input_energy_chp_local_wood_pellets_production' => 'input_energy_chp_local_ht_wood_pellets_production',
    'input_energy_chp_local_engine_biogas_production' => 'input_energy_chp_local_engine_ht_biogas_production',
    'input_energy_heat_well_geothermal_production' => 'input_energy_heat_well_deep_ht_geothermal_production',
    'input_energy_heat_burner_wood_pellets_production' => 'input_energy_heat_burner_ht_wood_pellets_production',
    'input_energy_heat_burner_waste_mix_production' => 'input_energy_heat_burner_ht_waste_mix_production',
    'input_energy_heat_burner_hydrogen_production' => 'input_energy_heat_burner_ht_hydrogen_production',
    'input_energy_heat_heatpump_water_water_electricity_production' => 'input_energy_heat_heatpump_water_water_ht_electricity_production',
    'input_energy_heat_boiler_electricity_production' => 'input_energy_heat_boiler_ht_electricity_production',
    'input_energy_heat_burner_network_gas_production' => 'input_energy_heat_burner_ht_network_gas_production',
    'input_energy_heat_burner_coal_production' => 'input_energy_heat_burner_ht_coal_production',
    'input_energy_heat_burner_crude_oil_production' => 'input_energy_heat_burner_ht_crude_oil_production',
    'input_energy_heat_solar_thermal_production' => 'input_energy_heat_solar_mt_solar_thermal_production',

    # full load hours
    'energy_chp_local_engine_network_gas_full_load_hours' => 'input_energy_chp_local_engine_network_gas_full_load_hours', 
    'energy_chp_combined_cycle_network_gas_full_load_hours' => 'input_energy_chp_combined_cycle_network_gas_full_load_hours', 
    'energy_chp_ultra_supercritical_cofiring_coal_full_load_hours' => 'input_energy_chp_ultra_supercritical_cofiring_coal_full_load_hours', 
    'energy_chp_ultra_supercritical_coal_full_load_hours' => 'input_energy_chp_ultra_supercritical_coal_full_load_hours', 
    'energy_chp_ultra_supercritical_lignite_full_load_hours' => 'input_energy_chp_ultra_supercritical_lignite_full_load_hours', 
    'energy_chp_local_wood_pellets_full_load_hours' => 'input_energy_chp_local_wood_pellets_full_load_hours', 
    'energy_chp_local_engine_biogas_full_load_hours' => 'input_energy_chp_local_engine_biogas_full_load_hours', 
    'energy_chp_supercritical_waste_mix_full_load_hours' => 'input_energy_chp_supercritical_waste_mix_full_load_hours', 
    'energy_heat_burner_coal_full_load_hours' => 'input_energy_heat_burner_coal_full_load_hours', 
    'energy_heat_burner_crude_oil_full_load_hours' => 'input_energy_heat_burner_crude_oil_full_load_hours', 
    'energy_heat_burner_network_gas_full_load_hours' => 'input_energy_heat_burner_network_gas_full_load_hours', 
    'energy_heat_burner_wood_pellets_full_load_hours' => 'input_energy_heat_burner_wood_pellets_full_load_hours', 
    'energy_heat_solar_thermal_full_load_hours' => 'input_energy_heat_solar_solar_thermal_full_load_hours', 
    'energy_heat_burner_waste_mix_full_load_hours' => 'input_energy_heat_burner_waste_mix_full_load_hours', 
    'energy_heat_heatpump_water_water_electricity_full_load_hours' => 'input_energy_heat_heatpump_water_water_electricity_full_load_hours'
  }.freeze

  def self.up
    # First grab the DatasetEdits that contain a change for the 'old' keys
    # to shrink the pool of datasets to search in below
    dataset_edits = DatasetEdit.where(key: KEYS.keys)

    # Replace all the old keys with the new keys, in batches
    KEYS.each do |old_key, new_key|
      dataset_edits.where(key: old_key).in_batches { |batch| batch.update_all(key: new_key) }
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
