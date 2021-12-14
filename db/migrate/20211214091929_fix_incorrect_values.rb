class FixIncorrectValues < ActiveRecord::Migration[5.2]
  EFFICIENCIES = {
    'households_final_demand_for_space_heating_network_gas_households_space_heater_combined_network_gas_parent_share' => 1.0, 
    'households_final_demand_for_space_heating_network_gas_households_space_heater_network_gas_parent_share' => 0.0,
    'households_final_demand_for_space_heating_network_gas_households_space_heater_hybrid_heatpump_air_water_electricity_parent_share' => 0.0
  }.freeze

  def self.up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.where(geo_id: ['SK','AT','BE','BG','CY','CZ','DE','DK','EE','EE','FI','FR','UK','EL','HR','HU','IE','IR','IT','LT','LU','LV','NL','PL','PT','RO','SE','SI']).each do |dataset|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No sufficient European source found.'
          )

          EFFICIENCIES.each do |key, value|
            create_edit(com, key, value)
          end
        end

      changed += 1
    end
    say "Finished (#{changed} updated)"
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
