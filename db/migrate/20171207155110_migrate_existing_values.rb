class MigrateExistingValues < ActiveRecord::Migration[5.0]
  def change
    changes = {
      'households_final_demand_electricity' => 'households_final_demand_electricity_demand',
      'households_final_demand_network_gas' => 'households_final_demand_network_gas_demand'
    }

    changes.each_pair do |old_key, new_key|
      DatasetEdit.where(key: old_key).update_all(key: new_key)
    end
  end
end
