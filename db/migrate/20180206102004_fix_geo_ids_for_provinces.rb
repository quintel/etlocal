class FixGeoIdsForProvinces < ActiveRecord::Migration[5.0]
  def up
    translations = {
      'zuid-holland' => 'zuid_holland',
      'noord-holland' => 'noord_holland',
      'noord-brabant' => 'noord_brabant',
    }

    translations.each_pair do |key, val|
      Dataset.find_by(geo_id: key).update_attribute(:geo_id, val)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
