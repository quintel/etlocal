class AddCommitMessageToVersions < ActiveRecord::Migration[5.0]
  def change
    add_column :versions, :commit_message, :string, after: :event
  end
end
