class EmissionKeysAllDatasets < ActiveRecord::Migration[8.1]
  EMISSION_KEYS = %w[
    industry_final_demand_for_chemical_fertilizers_network_gas_non_energetic_co2_demand
    industry_chemicals_fertilizers_emitted_co2_demand
    molecules_other_utilisation_co2_demand
  ].freeze

  def up
    Dataset.find_each do |dataset|
      ActiveRecord::Base.transaction do
        commit = Commit.create!(
          user: User.robot,
          dataset_id: dataset.id,
          message: 'Dynamic emission calculation, defaults to zero'
        )

        EMISSION_KEYS.each do |key|
          DatasetEdit.create!(
            commit_id: commit.id,
            key: key,
            value: 0.0
          )
        end
      end
    end
  end

  def down
    Dataset.find_each do |dataset|
      EMISSION_KEYS.each { |edit_key| destroy_edits(dataset, edit_key) }
    end
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
        commit.dataset_edits.find_by(key: edit_key).destroy
      end
    end
  end

  # Finds all commits belonging to a dataset with an edit to the given key.
  def find_commits(dataset, edit_key)
    dataset.commits
           .joins(:dataset_edits)
           .where(dataset_edits: { key: edit_key })
           .order(updated_at: :desc)
  end
end
