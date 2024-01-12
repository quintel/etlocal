class SetFutureTypicalHeatDemand < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting future typical heat demand of buildings and residences to nl2019 values for all datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|
        # next if dataset.queryable_source?

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available. Set to nl2019 values.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'typical_useful_demand_for_space_heating_buildings_future',
            value: 190.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'typical_useful_demand_for_space_heating_apartments_future',
            value: 65.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'typical_useful_demand_for_space_heating_detached_houses_future',
            value: 55.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'typical_useful_demand_for_space_heating_semi_detached_houses_future',
            value: 55.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'typical_useful_demand_for_space_heating_terraced_houses_future',
            value: 55.0
          )

          counter += 1
        end
      end
      counter
    end
  end
end
