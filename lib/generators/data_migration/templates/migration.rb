class <%= class_name.underscore.camelize %> < ActiveRecord::Migration[5.0]
  def self.up
    CSVImporter.run(
      Rails.root.join('db/migrate/<%= migration_number %>_<%= file_name %>/data.csv'),
      Rails.root.join('db/migrate/<%= migration_number %>_<%= file_name %>/commits.yml')
    )
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
