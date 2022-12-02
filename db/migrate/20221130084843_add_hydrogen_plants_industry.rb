class AddHydrogenPlantsIndustry < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting values for new hydrogen plants in industry for all datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available, set to default values'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'industry_chp_turbine_hydrogen_demand',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'industry_heat_burner_hydrogen_demand',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_industry_chp_turbine_hydrogen_electricity_output_conversion',
            value: 33.445
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_industry_chp_turbine_hydrogen_steam_hot_water_output_conversion',
            value: 41.472
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_industry_heat_burner_hydrogen_steam_hot_water_output_conversion',
            value: 100.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'industry_chp_turbine_hydrogen_full_load_hours',
            value: 8300.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'industry_heat_burner_hydrogen_full_load_hours',
            value: 7900.0
          )

          counter += 1
        end
      end
      counter
    end
  end
end
