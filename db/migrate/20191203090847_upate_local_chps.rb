class UpateLocalChps < ActiveRecord::Migration[5.0]
  def up
    old_gas_chp_households_key = 'input_households_district_heating_chp_network_gas_share'
    old_gas_chp_buildings_key = 'input_buildings_district_heating_chp_network_gas_share'
    old_gas_chp_agriculture_key = 'agriculture_chp_engine_network_gas_demand'
    new_gas_chp_key = 'input_energy_chp_local_engine_network_gas_production'
    gas_chp_electricity_conversion = 0.43
    gas_chp_steam_hot_water_conversion = 0.47

    old_wood_pellets_chp_households_key = 'input_households_district_heating_chp_wood_pellets_share'
    old_wood_pellets_chp_buildings_key = 'input_buildings_district_heating_chp_wood_pellets_share'
    old_wood_pellets_chp_agriculture_key = 'agriculture_chp_supercritical_wood_pellets_demand'
    new_wood_pellets_chp_key = 'input_energy_chp_local_wood_pellets_production'
    wood_pellets_chp_electricity_conversion = 0.2
    wood_pellets_chp_built_environment_steam_hot_water_conversion = 0.75

    old_biogas_chp_buildings_key = 'input_buildings_district_heating_chp_biogas_share'
    old_biogas_chp_agriculture_key = 'agriculture_chp_engine_biogas_demand'
    old_biogas_chp_central_key = 'input_energy_chp_engine_biogas_production'
    new_biogas_chp_key = 'input_energy_chp_local_engine_biogas_production'
    biogas_chp_electricity_conversion = 0.42
    biogas_chp_steam_hot_water_conversion = 0.35

    households_heat_demand_key = 'households_final_demand_steam_hot_water_demand'
    buildings_heat_demand_key = 'buildings_final_demand_steam_hot_water_demand'

    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      gas_chp_households_edit = find_edit(dataset, old_gas_chp_households_key)
      gas_chp_buildings_edit = find_edit(dataset, old_gas_chp_buildings_key)
      gas_chp_agriculture_edit = find_edit(dataset, old_gas_chp_agriculture_key)
      wood_pellets_chp_households_edit = find_edit(dataset, old_wood_pellets_chp_households_key)
      wood_pellets_chp_buildings_edit = find_edit(dataset, old_wood_pellets_chp_buildings_key)
      wood_pellets_chp_agriculture_edit = find_edit(dataset, old_wood_pellets_chp_agriculture_key)
      biogas_chp_buildings_edit = find_edit(dataset, old_biogas_chp_buildings_key)
      biogas_chp_agriculture_edit = find_edit(dataset, old_biogas_chp_agriculture_key)
      biogas_chp_central_edit = find_edit(dataset, old_biogas_chp_central_key)
      households_heat_demand_edit = find_edit(dataset, households_heat_demand_key)
      buildings_heat_demand_edit = find_edit(dataset, buildings_heat_demand_key)

      if [gas_chp_households_edit, gas_chp_buildings_edit, gas_chp_agriculture_edit, wood_pellets_chp_households_edit, wood_pellets_chp_buildings_edit, wood_pellets_chp_agriculture_edit, biogas_chp_buildings_edit, biogas_chp_agriculture_edit, biogas_chp_central_edit, households_heat_demand_edit, buildings_heat_demand_edit].all?
        gas_chp_households_share = gas_chp_households_edit.value
        gas_chp_buildings_share = gas_chp_buildings_edit.value
        gas_chp_agriculture_demand = gas_chp_agriculture_edit.value
        wood_pellets_chp_households_share = wood_pellets_chp_households_edit.value
        wood_pellets_chp_buildings_share  = wood_pellets_chp_buildings_edit.value
        wood_pellets_chp_agriculture_demand = wood_pellets_chp_agriculture_edit.value
        biogas_chp_buildings_share = biogas_chp_buildings_edit.value
        biogas_chp_agriculture_demand = biogas_chp_agriculture_edit.value
        biogas_chp_central_electricity_production = biogas_chp_central_edit.value
        households_heat_demand = households_heat_demand_edit.value
        buildings_heat_demand = buildings_heat_demand_edit.value

        gas_chp_built_environment_demand =
          ((gas_chp_households_share * households_heat_demand) +
          (gas_chp_buildings_share * buildings_heat_demand)) / gas_chp_steam_hot_water_conversion

        new_gas_chp_electricity_production =
          (gas_chp_agriculture_demand + gas_chp_built_environment_demand) * gas_chp_electricity_conversion

        wood_pellets_chp_built_environment_demand =
          ((wood_pellets_chp_households_share * households_heat_demand) +
          (wood_pellets_chp_buildings_share * buildings_heat_demand)) / wood_pellets_chp_built_environment_steam_hot_water_conversion

        new_wood_pellets_chp_electricity_production =
          (wood_pellets_chp_agriculture_demand + wood_pellets_chp_built_environment_demand) * wood_pellets_chp_electricity_conversion

        biogas_chp_buildings_demand =
          (biogas_chp_buildings_share * buildings_heat_demand) / biogas_chp_steam_hot_water_conversion

        new_biogas_chp_electricity_production =
          (biogas_chp_agriculture_demand + biogas_chp_buildings_demand) * biogas_chp_electricity_conversion +
          biogas_chp_central_electricity_production

        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: "Klimaatmonitor (2016). URL: https://klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5"
          )
          create_edit(com, new_gas_chp_key, new_gas_chp_electricity_production)
          create_edit(com, new_wood_pellets_chp_key, new_wood_pellets_chp_electricity_production)
          create_edit(com, new_biogas_chp_key, new_biogas_chp_electricity_production)
        end

        # Remove all outdated edits.
        destroy_edits(dataset, old_gas_chp_households_key)
        destroy_edits(dataset, old_gas_chp_buildings_key)
        destroy_edits(dataset, old_gas_chp_agriculture_key)
        destroy_edits(dataset, old_wood_pellets_chp_households_key)
        destroy_edits(dataset, old_wood_pellets_chp_buildings_key)
        destroy_edits(dataset, old_wood_pellets_chp_agriculture_key)
        destroy_edits(dataset, old_biogas_chp_buildings_key)
        destroy_edits(dataset, old_biogas_chp_agriculture_key)
        destroy_edits(dataset, old_biogas_chp_central_key)

        changed += 1
      end
    end

    say "Finished (#{changed} updated)"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
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

  # Finds all commits belonging to a dataset with an edit to the given key.
  def find_commits(dataset, edit_key)
    dataset.commits
           .joins(:dataset_edits)
           .where(dataset_edits: { key: edit_key })
           .order(updated_at: :desc)
  end

  # Finds the most recent edit of a key belonging to a dataset.
  def find_edit(dataset, edit_key)
    commits = find_commits(dataset, edit_key)

    return nil unless commits.any?

    DatasetEdit
      .where(commit_id: commits.pluck(:id), key: edit_key)
      .order(updated_at: :desc)
      .first
  end

  # Removes all dataset edits matching the `edit_key`. If the key is the only
  # dataset belonging to the commit, the commit will also be removed.
  def destroy_edits(dataset, edit_key)
    commits = find_commits(dataset, edit_key)

    return if commits.none?

    commits.each do |commit|
      if commit.dataset_edits.one?
        commit.destroy
      else
        commit.dataset_edits.find_by_key(edit_key).destroy
      end
    end
  end
end
