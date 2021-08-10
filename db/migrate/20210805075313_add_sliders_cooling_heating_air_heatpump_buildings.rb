class AddSlidersCoolingHeatingAirHeatpumpBuildings < ActiveRecord::Migration[5.2]
 NEW_SLIDERS = {
    'buildings_final_demand_for_cooling_electricity_buildings_cooling_heatpump_air_water_electricity_parent_share' => 0.0,
    'buildings_final_demand_for_space_heating_electricity_buildings_space_heater_heatpump_air_water_electricity_parent_share' => 0.0
  }.freeze

  def up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user: User.robot,
            dataset_id: dataset.id,
            message: 'Heatpump (air) for space heating and cooling has been added for buildings. No data available.'
          )

          NEW_SLIDERS.each do |key, value|
            create_edit(com, key, value)
          end
        end

      changed += 1
    end
    say "Finished (#{changed} updated)"
  end

  def down
    DatasetEdit.where(key: 'buildings_final_demand_for_cooling_electricity_buildings_cooling_heatpump_air_water_electricity_parent_share').delete_all
    DatasetEdit.where(key: 'buildings_final_demand_for_space_heating_electricity_buildings_space_heating_buildings_space_heating_heatpump_air_water_electricity_parent_share').delete_all
  end

  private

  # Create a new dataset edit
  def create_edit(commit, key, value)
    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: key,
        value: value
      )
    end
  end
end
