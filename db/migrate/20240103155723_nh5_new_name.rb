class Nh5NewName < ActiveRecord::Migration[7.0]
  def up
    say_with_time('Renaming geo_id Efate') do
      dataset = Dataset.find_by(geo_id: 'NH5')
      dataset.update!(geo_id: 'VUNH5')
    end
  end

  def down
    dataset = Dataset.find_by(geo_id: 'VUNH5')
    dataset.update!(geo_id: 'NH5')
  end
end


