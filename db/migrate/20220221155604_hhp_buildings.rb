class HhpBuildings < ActiveRecord::Migration[5.2]

  def up
    say_with_time('Setting HHP buildings to zero for all datasets') do
      counter = 0
      Dataset.where(data_source: 'db').find_each do |dataset|

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available. Set to 0.0.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'buildings_final_demand_for_space_heating_electricity_buildings_space_heater_hybrid_heatpump_air_water_electricity_parent_share',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'buildings_final_demand_for_space_heating_network_gas_buildings_space_heater_hybrid_heatpump_air_water_electricity_parent_share',
            value: 0.0
          )

          counter += 1
        end

        counter
      end
    end
  end
end
