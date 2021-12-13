# frozen_string_literal: true

class RenameNl2019DatasetToNl < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Rename nl dataset to nl2015') do
      Dataset.connection.execute(<<-SQL.squish)
        UPDATE datasets
        SET country = 'nl2015'
        WHERE country = 'nl'
      SQL
    end

    say_with_time('Rename nl2019 dataset to nl') do
      Dataset.connection.execute(<<-SQL.squish)
        UPDATE datasets
        SET country = 'nl'
        WHERE country = 'nl2019'
      SQL
    end
  end

  def down
    say_with_time('Rename nl dataset to nl2019') do
      Dataset.connection.execute(<<-SQL.squish)
        UPDATE datasets
        SET country = 'nl2019'
        WHERE country = 'nl'
      SQL
    end

    say_with_time('Rename nl2015 dataset to nl') do
      Dataset.connection.execute(<<-SQL.squish)
        UPDATE datasets
        SET country = 'nl'
        WHERE country = 'nl2015'
      SQL
    end
  end
end
