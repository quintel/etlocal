class RenameResDatasets < ActiveRecord::Migration[7.0]
  def change
    rename = {
      RES03: 'Regio Drenthe',
      RES06: 'Regio Friesland',
      RES11: 'Holland Rijnland',
      RES13: 'Rotterdam Denhaag',
      RES20: 'Noord Oost Brabant',
      RES26: 'Cleantechregio',
    }
    
    
    rename.each do |geo_id, new_name|
      regio = Dataset.where(geo_id: geo_id).first!
      regio.name = new_name
      regio.save!
    end
  end
end
