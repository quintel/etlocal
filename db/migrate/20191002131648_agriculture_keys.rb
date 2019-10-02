# frozen_string_literal: true

class AgricultureKeys < ActiveRecord::Migration[5.0]
  def up
    old_electricity_key = 'input_agriculture_electricity_demand'
    new_electricity_key = 'agriculture_final_demand_electricity_demand'

    old_steam_hot_water_key = 'input_agriculture_central_heat_demand'
    new_steam_hot_water_key = 'agriculture_final_demand_steam_hot_water_demand'

    old_geothermal_key = 'input_agriculture_geothermal_demand'

    gas_chp_key = 'agriculture_chp_engine_network_gas_demand'
    gas_chp_electricity_conversion = 0.43
    gas_chp_steam_hot_water_conversion = 0.47

    biogas_chp_key = 'agriculture_chp_engine_biogas_demand'
    biogas_chp_electricity_conversion = 0.42
    biogas_chp_steam_hot_water_conversion = 0.35

    wood_pellets_chp_key = 'agriculture_chp_supercritical_wood_pellets_demand'
    wood_pellets_chp_electricity_conversion = 0.2
    wood_pellets_chp_steam_hot_water_conversion = 0.85

    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      electricity_edit = find_edit(dataset, old_electricity_key)
      steam_hot_water_edit = find_edit(dataset, old_steam_hot_water_key)
      geothermal_edit = find_edit(dataset, old_geothermal_key)
      gas_chp_edit = find_edit(dataset, gas_chp_key)
      biogas_chp_edit = find_edit(dataset, biogas_chp_key)
      wood_pellets_chp_edit = find_edit(dataset, wood_pellets_chp_key)

      if [electricity_edit, steam_hot_water_edit, geothermal_edit, gas_chp_edit, biogas_chp_edit, wood_pellets_chp_edit].all?
        old_electricity_demand = electricity_edit.value
        old_steam_hot_water_demand = steam_hot_water_edit.value
        geothermal_demand = geothermal_edit.value
        gas_chp_demand = gas_chp_edit.value
        biogas_chp_demand = biogas_chp_edit.value
        wood_pellets_chp_demand = wood_pellets_chp_edit.value

        new_electricity_demand = old_electricity_demand +
          (gas_chp_demand * gas_chp_electricity_conversion) +
          (biogas_chp_demand * biogas_chp_electricity_conversion) +
          (wood_pellets_chp_demand * wood_pellets_chp_electricity_conversion)

        new_steam_hot_water_demand = old_steam_hot_water_demand +
          geothermal_demand +
          (gas_chp_demand * gas_chp_steam_hot_water_conversion) +
          (biogas_chp_demand * biogas_chp_steam_hot_water_conversion) +
          (wood_pellets_chp_demand * wood_pellets_chp_steam_hot_water_conversion)

        electricity_edit.key = new_electricity_key
        electricity_edit.value = new_electricity_demand

        electricity_edit.save(validate: false, touch: false)

        steam_hot_water_edit.key = new_steam_hot_water_key
        steam_hot_water_edit.value = new_steam_hot_water_demand

        steam_hot_water_edit.save(validate: false, touch: false)

        # Remove all outdated edits.
        destroy_edits(dataset, old_electricity_key)
        destroy_edits(dataset, old_steam_hot_water_key)
        destroy_edits(dataset, old_geothermal_key)

        changed += 1
      end
    end

    say "Finished (#{changed} updated)"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

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
