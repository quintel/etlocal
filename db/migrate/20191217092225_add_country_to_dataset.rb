class AddCountryToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :country, :string, after: :geo_id, default: 'nl'
  end
end
