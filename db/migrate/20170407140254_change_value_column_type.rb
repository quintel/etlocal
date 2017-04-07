class ChangeValueColumnType < ActiveRecord::Migration[5.0]
  require 'progress_bar'

  def change
    dataset_edits = Hash[DatasetEdit.all.map{|d| [d, d.value] }]
    bar = ProgressBar.new(DatasetEdit.count)

    DatasetEdit.update_all(value: nil)

    change_column :dataset_edits, :value, :float, precision: 15

    dataset_edits.each do |dataset, value|
      dataset.update_attribute(:value, value.to_f)
      bar.increment!
    end
  end
end
