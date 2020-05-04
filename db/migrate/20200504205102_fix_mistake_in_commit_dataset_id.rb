class FixMistakeInCommitDatasetId < ActiveRecord::Migration[5.2]
  def self.up
    commit = Commit.find_by(id: 305895)
    commit.dataset_id = 15064
    commit.save(validate: false, touch: false)

    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: 'analysis_year',
        value: 2017
      )

    edit = DatasetEdit.find_by(id: 18311716)
    edit.value = 0.15
    edit.save(validate: false, touch: false)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
