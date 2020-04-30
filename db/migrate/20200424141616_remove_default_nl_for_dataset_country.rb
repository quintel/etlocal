class RemoveDefaultNlForDatasetCountry < ActiveRecord::Migration[5.2]
  def up
    change_column_default :datasets, :country, nil
  end

  def down
    change_column_default :datasets, :country, 'nl'
  end
end
