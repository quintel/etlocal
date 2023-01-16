class AddChpsAgriculture < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting new agricultural CHPs demand to zero for all datasets, except EU') do
      counter = 0
      Dataset.all.find_each do |dataset|
        next if dataset.queryable_source?

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'New attribute (added to ETM in Dec 2022), set to zero.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_engine_network_gas_dispatchable_demand',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_engine_biogas_demand',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_wood_pellets_demand',
            value: 0.0
          )

          counter += 1
        end

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'New attribute (added to ETM in Dec 2022), set to a default value based on Netherlands 2019.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_engine_network_gas_dispatchable_electricity_output_conversion',
            value: 42.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_engine_network_gas_dispatchable_steam_hot_water_output_conversion',
            value: 50.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_engine_biogas_electricity_output_conversion',
            value: 42.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_engine_biogas_steam_hot_water_output_conversion',
            value: 39.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_wood_pellets_electricity_output_conversion',
            value: 18.3
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_agriculture_chp_wood_pellets_steam_hot_water_output_conversion',
            value: 47.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_wood_pellets_full_load_hours',
            value: 8500.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_engine_biogas_full_load_hours',
            value: 8500.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_chp_engine_network_gas_dispatchable_full_load_hours',
            value: 4500.0
          )

          counter += 1
        end

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'New attribute (added to ETM in Dec 2022). Assumed that all agricultural heat is produced by district heating.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_final_demand_local_steam_hot_water_agriculture_final_demand_steam_hot_water_child_share',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'agriculture_final_demand_central_steam_hot_water_agriculture_final_demand_steam_hot_water_child_share',
            value: 1.0
          )

          counter += 1
        end
      end
      counter
    end
  end
end
