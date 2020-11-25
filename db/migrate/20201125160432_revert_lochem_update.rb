class RevertLochemUpdate < ActiveRecord::Migration[5.2]
  def self.up
    Commit.destroy(321372)
    DatasetEdit.where(commit_id: 321372).destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
