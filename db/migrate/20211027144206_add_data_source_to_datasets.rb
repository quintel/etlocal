# frozen_string_literal: true

class AddDataSourceToDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :datasets, :data_source, :string, null: false, default: 'db', after: :geo_id
  end
end
