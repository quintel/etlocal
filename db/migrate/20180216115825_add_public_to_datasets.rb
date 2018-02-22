class AddPublicToDatasets < ActiveRecord::Migration[5.0]
  def change
    add_column :datasets, :public, :boolean, default: true, after: :has_agriculture
  end
end
