# frozen_string_literal: true

class RenameENTSOSourceToEnergyBalance < ActiveRecord::Migration[5.2]
  # rubocop:disable Rails/SkipsModelValidations

  def up
    Dataset.where(data_source: 'entso').update_all(data_source: 'energy_balance')
  end

  def down
    Dataset.where(data_source: 'energy_balance').update_all(data_source: 'entso')
  end

  # rubocop:enable Rails/SkipsModelValidations
end
