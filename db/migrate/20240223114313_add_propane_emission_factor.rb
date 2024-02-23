class AddPropaneEmissionFactor < ActiveRecord::Migration[7.0]
  
  KEYS = %w[
    file_carriers_propane_co2_conversion_per_mj
  ]

  def up
    say_with_time('Setting propane emission factor to set value for all datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Set to 0.06448 based on the update of the Netherlands list of fuels in 2021 by TNO'
          )

          create_edits_with_value(commit.id, *KEYS)

          counter += 1
        end

        counter
      end
    end
  end

  def create_edits_with_value(commit_id, *keys)
    keys.each do |key|
      DatasetEdit.create!(
        commit_id: commit_id,
        key: key,
        value: 0.06448
      )
    end
  end
end

