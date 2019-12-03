# frozen_string_literal: true

class MergeHeaters < ActiveRecord::Migration[5.0]
  def up
    households_geothermal_key = 'input_households_district_heating_geothermal_share'
    households_gas_heater_key = 'input_households_district_heating_heater_network_gas_share'
    households_hydrogen_heater_key = 'input_households_district_heating_heater_hydrogen_share'
    households_heatpump_key = 'input_households_district_heating_heatpump_electricity_share'
    households_heat_demand_key = 'households_final_demand_steam_hot_water_demand'

    buildings_geothermal_key = 'input_buildings_district_heating_geothermal_share'
    buildings_gas_heater_key = 'input_buildings_district_heating_heater_network_gas_share'
    buildings_hydrogen_heater_key = 'input_buildings_district_heating_heater_hydrogen_share'
    buildings_heatpump_key = 'input_buildings_district_heating_heatpump_electricity_share'
    buildings_heat_demand_key = 'buildings_final_demand_steam_hot_water_demand'

    energy_geothermal_key = 'input_energy_heater_for_heat_network_geothermal_production'
    energy_gas_heater_key = 'input_energy_heater_for_heat_network_network_gas_production'

    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      # calculate geothermal demand
      households_geothermal_demand = get_value(dataset, households_geothermal_key) * get_value(dataset, households_heat_demand_key)
      buildings_geothermal_demand = get_value(dataset, buildings_geothermal_key) * get_value(dataset, buildings_heat_demand_key)
      energy_geothermal_demand = get_value(dataset, energy_geothermal_key)

      new_geothermal_demand = households_geothermal_demand + buildings_geothermal_demand + energy_geothermal_demand

      # calculate gas heater demand
      households_gas_heater_demand = get_value(dataset, households_gas_heater_key) * get_value(dataset, households_heat_demand_key)
      buildings_gas_heater_demand = get_value(dataset, buildings_gas_heater_key) * get_value(dataset, buildings_heat_demand_key)
      energy_gas_heater_demand = get_value(dataset, energy_gas_heater_key)

      new_gas_heater_demand = households_gas_heater_demand + buildings_gas_heater_demand + energy_gas_heater_demand

      # calculate hydrogen heater demand
      households_hydrogen_heater_demand = get_value(dataset, households_hydrogen_heater_key) * get_value(dataset, households_heat_demand_key)
      buildings_hydrogen_heater_demand = get_value(dataset, buildings_hydrogen_heater_key) * get_value(dataset, buildings_heat_demand_key)

      new_hydrogen_heater_demand = households_hydrogen_heater_demand + buildings_hydrogen_heater_demand

      # calculate heat pump demand
      households_heatpump_demand = get_value(dataset, households_heatpump_key) * get_value(dataset, households_heat_demand_key)
      buildings_heatpump_demand = get_value(dataset, buildings_heatpump_key) * get_value(dataset, buildings_heat_demand_key)

      new_heatpump_demand = households_heatpump_demand + buildings_heatpump_demand

      ActiveRecord::Base.transaction do
        com = Commit.create!(
          user_id: 4,
          dataset_id: dataset.id,
          message: 'Klimaatmonitor (2016). URL: https://klimaatmonitor.databank.nl/Jive?workspace_guid=7d85d44f-1169-4d6e-bec3-b0307f9296f5'
        )

        create_edit(com, 'input_energy_heat_well_geothermal_production', new_geothermal_demand)
        create_edit(com, 'input_energy_heat_burner_network_gas_production', new_gas_heater_demand)
        create_edit(com, 'input_energy_heat_heatpump_water_water_electricity_production', new_heatpump_demand)
        create_edit(com, 'input_energy_heat_burner_hydrogen_production', new_hydrogen_heater_demand)
      end

      destroy_edits(dataset, households_geothermal_key)
      destroy_edits(dataset, households_gas_heater_key)
      destroy_edits(dataset, households_hydrogen_heater_key)
      destroy_edits(dataset, households_heatpump_key)

      destroy_edits(dataset, buildings_geothermal_key)
      destroy_edits(dataset, buildings_gas_heater_key)
      destroy_edits(dataset, buildings_hydrogen_heater_key)
      destroy_edits(dataset, buildings_heatpump_key)

      destroy_edits(dataset, energy_geothermal_key)
      destroy_edits(dataset, energy_gas_heater_key)

      changed += 1
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

  def get_value(dataset, edit_key, default: 0.0)
    edit = find_edit(dataset, edit_key)

    edit&.value || default
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
