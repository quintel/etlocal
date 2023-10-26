class EBoilerEfficiency < ActiveRecord::Migration[7.0]
  
  def up
    say_with_time('Setting e-boiler efficiency to 0.995 for all datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|
        next if dataset.queryable_source?

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on the general efficiency of e-boilers, not region specific.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_energy_heat_boiler_electricity_steam_hot_water_output_conversion',
            value: 99.5
          )

          counter += 1
        end
      end
      counter
    end
  end
end

