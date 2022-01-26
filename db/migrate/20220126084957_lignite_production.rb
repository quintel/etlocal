class LigniteProduction < ActiveRecord::Migration[5.2]

  def up
    Dataset.where(data_source: 'db').find_each do |dataset|
      next if dataset.group == 'country'

      ActiveRecord::Base.transaction do
        commit = Commit.create!(
          user_id: 4,
          dataset_id: dataset.id,
          message: 'Set to 0.0 as there is no energy production using lignite present in this area.'
        )

        DatasetEdit.create!(
          commit_id: commit.id,
          key: 'input_energy_chp_ultra_supercritical_lignite_production',
          value: 0.0
        )
      end
    end
  end
end
