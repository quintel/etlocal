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
    dataset_edits = DatasetEdit.where(key: KEYS.keys)

    KEYS.each do |old_key, new_key|
      dataset_edits.where(key: old_key).in_batches { |batch| batch.update_all(key: new_key) }
    end
  end

  # def self.up
  #   updated_count = 0
  #
  #   Dataset.find_each.with_index do |dataset, index|
  #     if index.positive? && (index % 500).zero?
  #       puts "#{index + 1} datasets checked - #{updated_count} updated"
  #     end
  #
  #     KEYS.each do |old_key, new_key|
  #       dataset_edit = find_edit(dataset, old_key)
  #
  #       next unless edit
  #
  #       dataset_edit.update_column(key: new_key)
  #
  #       destroy_edits(dataset, old_key)
  #
  #       updated_count += 1
  #     end
  #
  #   end
  #
  #   puts "Done! #{updated_count} datasets updated"
  # end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # Finds all commits belonging to a dataset with an edit to the given key.
  def find_commits(dataset, edit_key)
    dataset.commits
      .joins(:dataset_edits)
      .where(dataset_edits: { key: edit_key })
      .order(updated_at: :desc)
  end

  # Finds the most recent edit of a key belonging to a dataset.
  def find_edit(dataset, edit_key)
    commits = find_commits(dataset, edit_key)

    return nil unless commits.any?

    DatasetEdit
      .where(commit_id: commits.pluck(:id), key: edit_key)
      .order(updated_at: :desc)
      .first
  end

  # Removes all dataset edits matching the `edit_key`. If the key is the only
  # dataset belonging to the commit, the commit will also be removed.
  def destroy_edits(dataset, edit_key)
    commits = find_commits(dataset, edit_key)

    return if commits.none?

    commits.each do |commit|
      if commit.dataset_edits.one?
        commit.destroy
      else
        commit.dataset_edits.where(key: edit_key).destroy_all
      end
    end
  end
end
