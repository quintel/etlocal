class AddTypeToDatasetEdits < ActiveRecord::Migration[7.2]
  def change
    add_column :dataset_edits, :type, :string
    add_column :dataset_edits, :boolean_value, :boolean
  end
end
