class Aquathermal < ActiveRecord::Migration[7.0]
  
  KEYS = %w[
    input_energy_heat_heatpump_surface_water_ts_lt_electricity_production
    input_energy_heat_heatpump_surface_water_ts_mt_electricity_production
    input_energy_heat_heatpump_waste_water_ts_lt_electricity_production
    input_energy_heat_heatpump_waste_water_ts_mt_electricity_production
    input_energy_heat_heatpump_drink_water_ts_lt_electricity_production
    input_energy_heat_heatpump_drink_water_ts_mt_electricity_production
    aquathermal_potential_for_surface_water
    aquathermal_potential_for_waste_water
    aquathermal_potential_for_drink_water
  ]

  def up
    say_with_time('Setting aquathermal keys to zero for all datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available. Set to 0.0.'
          )

          create_edits_with_zero(commit.id, *KEYS)

          counter += 1
        end

        counter
      end
    end
  end

  def create_edits_with_zero(commit_id, *keys)
    keys.each do |key|
      DatasetEdit.create!(
        commit_id: commit_id,
        key: key,
        value: 0.0
      )
    end
  end
end

