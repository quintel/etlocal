class DisallowNullDatasetFields < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        execute 'UPDATE datasets SET area = geo_id WHERE area IS NULL'
      end

      dir.down do
        # Don't revert setting the area to geo_id when migrating up; there's no
        # harm in the value being set and we may accidentally set NULL values
        # for datasets where the area was explicitly set to the geo_id
      end
    end

    change_column_null :datasets, :geo_id, false
    change_column_null :datasets, :area,   false
  end
end
