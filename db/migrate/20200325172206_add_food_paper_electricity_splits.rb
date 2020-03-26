class AddFoodPaperElectricitySplits < ActiveRecord::Migration[5.2]
 def up
   new_keys = {
    'industry_final_demand_for_other_food_electricity_industry_other_food_heater_electricity_parent_share' => 0.0,
    'industry_final_demand_for_other_food_electricity_industry_useful_demand_for_other_food_electricity_parent_share' => 1.0,
    'industry_final_demand_for_other_paper_electricity_industry_other_paper_heater_electricity_parent_share' => 0.0,
    'industry_final_demand_for_other_paper_electricity_industry_useful_demand_for_other_paper_electricity_parent_share' => 1.0
    }
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each.with_index do |dataset, index|
      if index.positive? && (index % 500).zero?
        say "Done #{index} (#{changed} updated)"
      end

      ActiveRecord::Base.transaction do
        com = Commit.create!(
          user_id: 4,
          dataset_id: dataset.id,
          message: 'Gebaseerd op Nederlands gemiddelde'
        )

        new_keys.each do |key, value|
          create_edit(com, key, value)
        end
      end
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

