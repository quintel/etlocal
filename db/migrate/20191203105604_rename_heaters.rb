# frozen_string_literal: true

class RenameHeaters < ActiveRecord::Migration[5.0]
  RENAMED_KEYS = {
    'input_energy_heater_for_heat_network_crude_oil_production' => 'input_energy_heat_burner_crude_oil_production',
    'input_energy_heater_for_heat_network_coal_production' => 'input_energy_heat_burner_coal_production',
    'input_energy_heater_for_heat_network_waste_mix_production' => 'input_energy_heat_burner_waste_mix_production',
    'input_energy_heater_for_heat_network_wood_pellets_production' => 'input_energy_heat_burner_wood_pellets_production'
  }.freeze

  def up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      key_altered = false

      RENAMED_KEYS.each do |old_key, new_key|
        edit = find_edit(dataset, old_key)

        if edit
          edit.key = new_key
          edit.save(validate: false, touch: false)
          destroy_edits(dataset, old_key)

          key_altered = true
        end
      end

      if key_altered
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
