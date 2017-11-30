class RenameDatasetEdits < ActiveRecord::Migration[5.0]
  def change
    changes = {
      'electricity_consumption' => 'households_final_demand_electricity',
      'gas_consumption' => 'households_final_demand_network_gas'
    }

    changes.each_pair do |old_key, new_key|
      DatasetEdit.where(key: old_key).update_all(key: new_key)
    end
  end
end
