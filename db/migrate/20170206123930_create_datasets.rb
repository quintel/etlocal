class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets do |t|
      t.string :title
      t.timestamps
    end

    add_attachment :datasets, :dataset_file
  end
end
