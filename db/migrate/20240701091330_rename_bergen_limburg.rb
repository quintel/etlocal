class RenameBergenLimburg < ActiveRecord::Migration[7.0]
  def change
    rename = {
      GM0893: 'Bergen'
    }
    
    rename.each do |geo_id, new_name|
      regio = Dataset.where(geo_id: geo_id).first!
      regio.name = new_name
      regio.save!
    end
  end
end
