class RenameCarbonInputs < ActiveRecord::Migration[7.2]
  RENAME = {
    energy_distribution_biogenic_waste_energy_distribution_waste_mix_child_share: :input_percentage_of_biogenic_waste_energy_distribution_waste_mix,
    energy_distribution_non_biogenic_waste_energy_distribution_waste_mix_child_share: :input_percentage_of_non_biogenic_waste_energy_distribution_waste_mix
  }

  def change
    RENAME.each do |old_key, new_key|
      DatasetEdit.where(key: old_key).update_all(key: new_key)
    end
  end
end
