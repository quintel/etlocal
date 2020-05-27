class RemoveTempAntwerpCommit < ActiveRecord::Migration[5.2]
  def self.up
    Commit.destroy(259355)
    DatasetEdit.where(commit_id: 259355).destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
