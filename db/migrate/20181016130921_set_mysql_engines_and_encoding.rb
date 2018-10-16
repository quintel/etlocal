class SetMysqlEnginesAndEncoding < ActiveRecord::Migration[5.0]
  def up
    unless ActiveRecord::Base.connection.adapter_name.downcase =~ /^mysql/
      return
    end

    # https://stackoverflow.com/a/31474509
    change_column :users, :email, :string, limit: 191, null: false
    change_column :users, :reset_password_token, :string, limit: 191

    tables = %i[
      ar_internal_metadata
      commits
      dataset_edits
      datasets
      groups
      schema_migrations
      sources
      users
    ]

    tables.each do |table|
      say_with_time "Updating #{table}" do
        ActiveRecord::Base.connection.execute(
          "ALTER TABLE `#{table}` ENGINE = InnoDB"
        )

        ActiveRecord::Base.connection.execute(
          "ALTER TABLE #{table} " \
          'CONVERT TO CHARACTER SET utf8mb4 ' \
          'COLLATE utf8mb4_general_ci'
        )
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
