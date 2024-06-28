class RenameGreengasKeys < ActiveRecord::Migration[7.0]
  
  # old_key => new_key
  KEYS = {
    'energy_greengas_gasification_dry_biomass_energy_distribution_greengas_child_share' => 'energy_greengas_gasification_dry_biomass_energy_greengas_production_child_share',
    'energy_greengas_gasification_wet_biomass_energy_distribution_greengas_child_share' => 'energy_greengas_gasification_wet_biomass_energy_greengas_production_child_share',
    'energy_greengas_upgrade_biogas_energy_distribution_greengas_child_share' => 'energy_greengas_upgrade_biogas_energy_greengas_production_child_share'
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

end
