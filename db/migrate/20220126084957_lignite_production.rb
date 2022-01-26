class LigniteProduction < ActiveRecord::Migration[5.2]

  def up
    Dataset.find_each do |dataset|
      if dataset.group != 'municipality'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Set to 0.0 as there is no energy production using lignite present in this area.'
          )
          create_edit(com, input_energy_chp_ultra_supercritical_lignite_production, 0.0)
        end
      end
    end
  end

  private

  # Create a new dataset edit
  def create_edit(commit, key, value)
    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: key,
        value: value
      )
    end
  end
end
