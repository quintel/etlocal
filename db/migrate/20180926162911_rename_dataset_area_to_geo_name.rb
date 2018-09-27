class RenameDatasetAreaToGeoName < ActiveRecord::Migration[5.0]
  def change
    rename_column :datasets, :area, :name
  end
end
