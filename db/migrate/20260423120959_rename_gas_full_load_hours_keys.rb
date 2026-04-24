class RenameGasFullLoadHoursKeys < ActiveRecord::Migration[7.0]

  # old_key => new_key
  KEYS = {
    'energy_power_combined_cycle_network_gas_full_load_hours' => 'input_energy_power_combined_cycle_network_gas_full_load_hours',
    'energy_power_turbine_network_gas_full_load_hours' => 'input_energy_power_turbine_network_gas_full_load_hours'
  }.freeze

  def self.up
    dataset_edits = DatasetEdit.where(key: KEYS.keys)

    KEYS.each do |old_key, new_key|
      dataset_edits.where(key: old_key).in_batches { |batch| batch.update_all(key: new_key) }
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
