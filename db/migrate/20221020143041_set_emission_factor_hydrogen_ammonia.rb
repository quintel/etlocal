class SetEmissionFactorHydrogenAmmonia < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting emission factors for hydrogen & ammonia for all datasets to the same value') do
      counter = 0
      Dataset.all.find_each do |dataset|

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'For sources see general documentation Excel on GitHub: https://github.com/quintel/etdataset/blob/master/carriers_source_analyses/imported_hydrogen.carrier.xlsx'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'file_carriers_imported_hydrogen_co2_conversion_per_mj',
            value: 0.078
          )

          counter += 1
        end

        ActiveRecord::Base.transaction do
            commit = Commit.create!(
              user_id: 4,
              dataset_id: dataset.id,
              message: 'For sources see general documentation Excel on GitHub: https://github.com/quintel/etdataset/blob/master/carriers_source_analyses/imported_ammonia.carrier.xlsx'
            )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'file_carriers_imported_ammonia_co2_conversion_per_mj',
            value: 0.096774194
          )

          counter += 1
        end

        counter
      end
    end
  end
end