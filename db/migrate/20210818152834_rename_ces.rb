class RenameCes < ActiveRecord::Migration[5.2]
  def self.up
    dataset = Dataset.find_by(geo_id: 'CES01_NKZG')
    dataset.geo_id = 'CES01'
    dataset.save(validate: false, touch: false)
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
