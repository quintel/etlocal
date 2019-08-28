# frozen_string_literal: true

class CombineGreengasImportAndProduction < ActiveRecord::Migration[5.0]
  def up
    production_key = 'input_energy_greengas_production'
    import_key = 'energy_import_greengas_demand'
    new_key = 'energy_distribution_greengas_demand'

    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      production_edit = find_edit(dataset, production_key)
      import_edit = find_edit(dataset, import_key)

      # Every dataset we have specifies either both keys (in which case both
      # edits will be present), or neither.
      if production_edit && import_edit
        import_edit.key = new_key
        import_edit.value += production_edit.value

        import_edit.save(validate: false, touch: false)

        # Remove all outdated edits.
        destroy_edits(dataset, production_key)
        destroy_edits(dataset, import_key)

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
