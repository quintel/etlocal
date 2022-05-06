require 'rails/generators/active_record/migration/migration_generator'

class DataMigrationGenerator < ActiveRecord::Generators::MigrationGenerator
  source_root File.expand_path('../templates', __FILE__)

  def create_migration_file
    set_local_assigns!
    validate_file_name!

    migration_template('migration.rb', "db/migrate/#{file_name}.rb")

    FileUtils.mkdir("db/migrate/#{migration_number}_#{file_name}")

    copy_data_file 'data.csv'
    copy_data_file 'commits.yml'
  end

  private

  def copy_data_file(source)
    template(
      File.expand_path(find_in_source_paths(source.to_s)),
      "db/migrate/#{migration_number}_#{file_name}/#{source}"
    )
  end
end
