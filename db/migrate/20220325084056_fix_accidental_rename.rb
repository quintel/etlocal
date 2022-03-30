class FixAccidentalRename < ActiveRecord::Migration[5.2]
  def change
    Dataset.find_by(geo_id: 'RES26').update(name: 'Cleantechregio')
    Dataset.find_by(geo_id: 'PV24').update(name: 'Flevoland')
  end
end
