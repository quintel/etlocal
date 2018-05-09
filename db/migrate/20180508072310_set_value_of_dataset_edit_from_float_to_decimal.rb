class SetValueOfDatasetEditFromFloatToDecimal < ActiveRecord::Migration[5.0]
  def change
    change_column :dataset_edits, :value, :double
  end
end
