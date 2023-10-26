class EBoilerEfficiency < ActiveRecord::Migration[7.0]
  
  EFFICIENCIES = {
    'input_energy_heat_boiler_electricity_steam_hot_water_output_conversion' => 99.5
  }.freeze

  def up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user: User.robot,
            dataset_id: dataset.id,
            message: 'Efficiency researched by Quintel. Source data can be found below the slider of this plant in the ETM front-end'
          )

          EFFICIENCIES.each do |key, value|
            create_edit(com, key, value)
          end
        end

      changed += 1
    end
    say "Finished (#{changed} updated)"
  end

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
