class RenameEfateDataset < ActiveRecord::Migration[7.0]
  def change
    rename = {
      NH5: 'VUNH5'
    }
    
    
    rename.each do |geo_id, new_geo_id|
      regio = Dataset.where(geo_id: geo_id).first!
      regio.geo_id = new_geo_id
      regio.save!
    end
  end
end
