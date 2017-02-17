class RenameAreaToDatasetIdDatasetEdits < ActiveRecord::Migration[5.0]
  def change
    remove_column :dataset_edits, :area
    add_column :dataset_edits, :dataset_id, :integer, after: :source_id
  end
end
