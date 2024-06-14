class RenameWindOffshoreFlhKey < ActiveRecord::Migration[7.0]
  
  # old_key => new_key
  KEYS = {
    'energy_power_wind_turbine_offshore_full_load_hours' => 'input_energy_power_wind_turbine_offshore_full_load_hours'
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
