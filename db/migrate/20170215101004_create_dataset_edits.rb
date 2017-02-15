class CreateDatasetEdits < ActiveRecord::Migration[5.0]
  def change
    create_table :dataset_edits do |t|
      t.belongs_to(:user)
      t.belongs_to(:source)
      t.string :commit
      t.string :area
      t.string :key
      t.string :value
      t.timestamps
    end
  end
end
