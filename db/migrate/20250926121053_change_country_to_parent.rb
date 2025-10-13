class ChangeCountryToParent < ActiveRecord::Migration[7.2]
  def change
    rename_column :datasets, :country, :parent
  end
end
