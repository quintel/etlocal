class NlNeighbourhoordsNumberOfVansTrucksBusses < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting number of vehicles for all neighbourhood datasets') do
      counter = 0
      Dataset.all.find_each do |dataset|
        next unless dataset.group == "neighbourhood"

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available for this region, set to zero.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'number_of_vans',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'number_of_busses',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'number_of_trucks',
            value: 0.0
          )

          counter += 1
        end

        counter
      end
    end
  end
end
