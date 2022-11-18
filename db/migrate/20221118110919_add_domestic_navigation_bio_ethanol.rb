class AddDomesticNavigationBioEthanol < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting bio-ethanol domestic navigation demand to zero for all datasets, except EU') do
      counter = 0
      Dataset.all.find_each do |dataset|
        next if dataset.queryable_source?

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on country-level energy balance data bio-ethanol demand for domestic navigation is 0.0'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_transport_ship_bio_ethanol_demand',
            value: 0.0
          )

          counter += 1
        end
      end
      counter
    end
  end
end
