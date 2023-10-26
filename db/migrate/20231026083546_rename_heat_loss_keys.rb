class RenameHeatLossKeys < ActiveRecord::Migration[7.0]
  
  # old_key => new_key
  KEYS = {
    # loss
    'energy_heat_distribution_ht_loss_share' => 'input_energy_heat_distribution_ht_loss_share',
    'energy_heat_distribution_mt_loss_share' => 'input_energy_heat_distribution_mt_loss_share',
    'energy_heat_distribution_lt_loss_share' => 'input_energy_heat_distribution_lt_loss_share'
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
