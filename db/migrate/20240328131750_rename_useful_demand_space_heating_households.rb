class RenameUsefulDemandSpaceHeatingHouseholds < ActiveRecord::Migration[7.0]
  INPUTS = %w[
    input_present_share_of_apartments_before_1945_in_useful_demand_for_space_heating
    input_present_share_of_apartments_1945_1964_in_useful_demand_for_space_heating
    input_present_share_of_apartments_1965_1984_in_useful_demand_for_space_heating
    input_present_share_of_apartments_1985_2004_in_useful_demand_for_space_heating
    input_present_share_of_apartments_2005_present_in_useful_demand_for_space_heating
    input_present_share_of_detached_houses_before_1945_in_useful_demand_for_space_heating
    input_present_share_of_detached_houses_1945_1964_in_useful_demand_for_space_heating
    input_present_share_of_detached_houses_1965_1984_in_useful_demand_for_space_heating
    input_present_share_of_detached_houses_1985_2004_in_useful_demand_for_space_heating
    input_present_share_of_detached_houses_2005_present_in_useful_demand_for_space_heating
    input_present_share_of_semi_detached_houses_before_1945_in_useful_demand_for_space_heating
    input_present_share_of_semi_detached_houses_1945_1964_in_useful_demand_for_space_heating
    input_present_share_of_semi_detached_houses_1965_1984_in_useful_demand_for_space_heating
    input_present_share_of_semi_detached_houses_1985_2004_in_useful_demand_for_space_heating
    input_present_share_of_semi_detached_houses_2005_present_in_useful_demand_for_space_heating
    input_present_share_of_terraced_houses_before_1945_in_useful_demand_for_space_heating
    input_present_share_of_terraced_houses_1945_1964_in_useful_demand_for_space_heating
    input_present_share_of_terraced_houses_1965_1984_in_useful_demand_for_space_heating
    input_present_share_of_terraced_houses_1985_2004_in_useful_demand_for_space_heating
    input_present_share_of_terraced_houses_2005_present_in_useful_demand_for_space_heating
  ]

  def change
    INPUTS.each do |old_input_key|
      # Remove the word 'input_' from key, and divide value by 100
      DatasetEdit.where(key: old_input_key).find_each(batch_size: 10) do |edit|
        edit.key = old_input_key[6..]
        edit.value = edit.value / 100.0

        edit.save!
      end
    end
  end
end
