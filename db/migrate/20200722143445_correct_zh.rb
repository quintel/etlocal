class CorrectZh < ActiveRecord::Migration[5.2]
  def self.up
    Commit.destroy(319323)
    DatasetEdit.where(commit_id: 319323).destroy_all

    edit_one = DatasetEdit.find_by(id: 18402108)
    edit_one.value = 59697.88808
    edit_one.save(validate: false, touch: false)

    edit_two = DatasetEdit.find_by(id: 18402122)
    edit_two.value = 34402.8538
    edit_two.save(validate: false, touch: false)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
