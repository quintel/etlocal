class SetMysqlCollationToUtf8mb4Unicode < ActiveRecord::Migration[5.0]
  def change
    unless ActiveRecord::Base.connection.adapter_name.downcase =~ /^mysql/
      return
    end

    reversible do |dir|
      dir.up do
        update_collation!('utf8mb4_unicode_ci')

        # Updating to mb4 switches TEXT columns to MEDIUMTEXT. This isn't needed
        # for commit messages.
        change_column :commits, :message, :text, limit: 64.kilobytes - 1
      end

      dir.down { update_collation!('utf8mb4_general_ci') }
    end
  end

  private

  def update_collation!(collation)
    say_with_time 'Updating database' do
      ActiveRecord::Base.connection.execute(<<~SQL)
        ALTER DATABASE #{ActiveRecord::Base.connection.current_database}
        CHARACTER SET = utf8mb4
        COLLATE = #{collation}
      SQL
    end

    ActiveRecord::Base.connection.tables.each do |table|
      say_with_time "Updating #{table}" do
        ActiveRecord::Base.connection.execute(<<~SQL)
          ALTER TABLE #{table}
          CONVERT TO CHARACTER SET utf8mb4
          COLLATE #{collation}
        SQL
      end
    end
  end
end
