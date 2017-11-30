class AddHasIndustryAndHasAgricultureTogglesToDataset < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :has_agriculture, :boolean, default: false, after: :geo_id
    add_column :datasets, :has_industry, :boolean, default: false, after: :geo_id
  end
end
