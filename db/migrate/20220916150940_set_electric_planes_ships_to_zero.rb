class SetElectricPlanesShipsToZero < ActiveRecord::Migration[5.2]
  def up
    say_with_time('Setting electric planes and ships to zero for all datasets, except EU') do
      counter = 0
      Dataset.all.find_each do |dataset|
        next if dataset.queryable_source?

        ActiveRecord::Base.transaction do
          commit = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'No data available. Set to 0.0.'
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_transport_plane_electricity_demand',
            value: 0.0
          )

          DatasetEdit.create!(
            commit_id: commit.id,
            key: 'input_transport_ship_electricity_demand',
            value: 0.0
          )

          counter += 1
        end
      end
      counter
    end
  end
end
