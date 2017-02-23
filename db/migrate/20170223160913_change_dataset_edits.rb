class ChangeDatasetEdits < ActiveRecord::Migration[5.0]
  def change
    add_reference :dataset_edits, :commit, after: :id

    remove_column :dataset_edits, :user_id
    remove_column :dataset_edits, :dataset_id
    remove_column :dataset_edits, :source_id
    remove_column :dataset_edits, :commit
  end
end
