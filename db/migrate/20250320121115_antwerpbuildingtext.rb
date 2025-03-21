class Antwerpbuildingtext < ActiveRecord::Migration[5.0]
def change
  new_message = "Based on the valid EPC certifications and assumption that approximately 1/3th of small residential buildings have an EPC certification. The approximated value is multiplied by 4 to align with heat technology settings of ETM (fixed value)."

  Commit.where(dataset: Dataset.find_by(geo_id: :BEGM11002))
    .joins(:dataset_edits)
    .where(dataset_edits: { key: "present_number_of_buildings" })
    .last
    .update(message: new_message)
end
end
