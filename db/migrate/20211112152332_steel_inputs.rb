class SteelInputs < ActiveRecord::Migration[5.2]
  SCALABLE_STEEL_KEYS = {
    input_industry_metal_steel_production: { nl2015: 6.995, nl: 6.995 },
    input_industry_metal_steel_coal_demand: { nl2015: 2523.05, nl: 2523.05 },
    input_industry_metal_steel_cokes_demand: { nl2015: 3477.01, nl: 3477.01 },
    input_industry_metal_steel_coal_gas_demand: { nl2015: 19180.4, nl: 19180.4 },
    input_industry_metal_steel_electricity_demand: { nl2015: 9458.9, nl: 9458.9 },
    input_industry_metal_steel_network_gas_demand: { nl2015: 10694.660413136162, nl: 10694.660413136162 },
    input_industry_metal_steel_steam_hot_water_demand: { nl2015: 1.0, nl: 1.0 },
    input_industry_metal_steel_wood_pellets_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_metal_steel_crude_oil_demand: { nl2015: 170.4, nl: 170.4 },
    input_energy_cokesoven_transformation_coal_input_demand: { nl2015: 68491.72085616566, nl: 68491.72085616566 },
    input_energy_cokesoven_own_use_coal: { nl2015: 0.0, nl: 0.0 },
    input_energy_cokesoven_own_use_cokes: { nl2015: 0.0, nl: 0.0 },
    input_energy_cokesoven_own_use_coal_gas: { nl2015: 8032.1699999999655, nl: 8032.1699999999655 },
    input_energy_cokesoven_own_use_electricity: { nl2015: 324.06, nl: 324.06 },
    input_energy_cokesoven_own_use_network_gas: { nl2015: 0.0, nl: 0.0 },
    input_energy_cokesoven_own_use_steam_hot_water: { nl2015: 0.0, nl: 0.0 },
    input_energy_cokesoven_own_use_crude_oil: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_transformation_coal_input_demand: { nl2015: 33859.10235451842, nl: 33859.10235451842 },
    input_energy_blastfurnace_transformation_cokes_input_demand: { nl2015: 43075.454608131906, nl: 43075.454608131906 },
    input_energy_blastfurnace_own_use_coal: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_cokes: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_coal_gas: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_electricity: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_network_gas: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_steam_hot_water: { nl2015: 0.0, nl: 0.0 },
    input_energy_blastfurnace_own_use_crude_oil: { nl2015: 0.0, nl: 0.0 },
    input_energy_power_combined_cycle_coal_gas_coal_gas_input_demand: { nl2015: 17342.733397857177, nl: 17342.733397857177 },
    input_energy_chp_coal_gas_coal_gas_input_demand: { nl2015: 8696.74, nl: 8696.74 },
  }.freeze

  UNSCALABLE_STEEL_KEYS = {
    input_industry_steel_blastfurnace_bof_share: { nl2015: 0.9847033595425303, nl: 0.9847033595425303 },
    input_energy_cokesoven_transformation_cokes_output_conversion: { nl2015: 0.710233550857932, nl: 0.710233550857932 },
    input_energy_cokesoven_transformation_coal_gas_output_conversion: { nl2015: 0.201181414633627, nl: 0.201181414633627 },
    input_energy_blastfurnace_transformation_coal_gas_output_conversion: { nl2015: 0.400028846858287, nl: 0.400028846858287 },
    input_energy_power_combined_cycle_coal_gas_electricity_output_conversion: { nl2015: 0.3792423456, nl: 0.3792423456 },
    input_energy_chp_coal_gas_steam_hot_water_output_conversion: { nl2015: 0.02794150452, nl: 0.02794150452 },
    input_energy_chp_coal_gas_electricity_output_conversion: { nl2015: 0.423469024, nl: 0.423469024 },
    industry_final_demand_for_metal_steel_electricity_industry_steel_blastfurnace_bof_parent_share: { nl2015: 0.977068424256256, nl: 0.977068424256256 },
    industry_final_demand_for_metal_steel_network_gas_industry_steel_blastfurnace_bof_parent_share: { nl2015: 0.98781761265, nl: 0.98781761265 },
    industry_final_demand_for_metal_steel_coal_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0 }
  }.freeze

  def up
    say_with_time('Setting steel inputs for non nl datasets') do
      counter = 0
      Dataset.where.not(country: :nl).each do |dataset|
        commit = dataset.commits.build(
          message: 'No data provided.',
          user: User.robot
        )
        SCALABLE_STEEL_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        UNSCALABLE_STEEL_KEYS.each { |key, values| commit.dataset_edits.build(key: key, value: values[:nl2015]) }

        commit.save!
        counter += 1
      end

      counter
    end

    say_with_time('Calculating and setting steel inputs for nl datasets') do
      counter = 0

      Dataset.where(country: :nl).each do |dataset|
        # NOTE: this scaling factor is now ususally empty. We save it with saying it's 0. Please
        # change that if you want other behaviour.
        factor = dataset.editable_attributes.find("input_industry_metal_steel_scaling_factor").value || 0
        commit = dataset.commits.build(
          message: "Schatting Quintel op basis van emissiegegevens en Nederlandse energiebalans.
            URL: http://www.emissieregistratie.nl",
          user: User.robot
        )

        SCALABLE_STEEL_KEYS.each do |key, values|
          base_value = is_2019?(dataset) ? values[:nl] : values[:nl2015]
          commit.dataset_edits.build(key: key, value: base_value * factor)
        end

        UNSCALABLE_STEEL_KEYS.each do |key, values|
          base_value = is_2019?(dataset) ? values[:nl] : values[:nl2015]
          commit.dataset_edits.build(key: key, value: base_value)
        end

        commit.save!
        counter += 1
      end

      counter
    end
  end

  def is_2019?(dataset)
    dataset.editable_attributes.find(:analysis_year) == 2019
  end

  def down
    say_with_time('Removing all DatasetEdits for steel keys') do
      SCALABLE_STEEL_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
      UNSCALABLE_STEEL_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
    end
  end
end
