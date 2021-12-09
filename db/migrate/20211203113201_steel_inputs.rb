class SteelInputs < ActiveRecord::Migration[5.2]

  # Results of:
  # [
  # V(industry_steel_production, demand)/BILLIONS,
  # V(industry_final_demand_for_metal_steel_coal, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_cokes, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_coal_gas, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_electricity, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_network_gas, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_steam_hot_water, demand)/MILLIONS,
  # V(industry_final_demand_for_metal_steel_crude_oil, demand)/MILLIONS,
  # V(energy_cokesoven_transformation_coal, input_of_coal)/MILLIONS,
  # V(energy_cokesoven_own_use, input_of_coal_gas)/MILLIONS,
  # V(energy_cokesoven_own_use, input_of_electricity)/MILLIONS,
  # V(energy_blastfurnace_transformation_cokes, input_of_coal)/MILLIONS,
  # V(energy_blastfurnace_transformation_cokes, input_of_cokes)/MILLIONS,
  # V(energy_power_combined_cycle_coal_gas, input_of_coal_gas)/MILLIONS,
  # V(energy_chp_coal_gas, input_of_coal_gas)/MILLIONS,
  # V(EDGE(industry_steel_production, industry_steel_blastfurnace_bof), share),
  # V(energy_cokesoven_transformation_coal, cokes_output_conversion),
  # V(energy_cokesoven_transformation_coal, coal_gas_output_conversion),
  # V(energy_blastfurnace_transformation_cokes, coal_gas_output_conversion),
  # V(energy_power_combined_cycle_coal_gas, electricity_output_conversion),
  # V(energy_chp_coal_gas, steam_hot_water_output_conversion),
  # V(energy_chp_coal_gas, electricity_output_conversion),
  # V(EDGE(industry_steel_blastfurnace_bof, industry_final_demand_for_metal_steel_electricity), parent_share),
  # V(EDGE(industry_steel_blastfurnace_bof, industry_final_demand_for_metal_steel_network_gas), parent_share),
  # V(EDGE(industry_steel_blastfurnace_bof, industry_final_demand_for_metal_steel_coal), parent_share),
  # 0.0,
  # 0.0,
  # V(energy_chp_coal_gas, full_load_hours),
  # V(energy_power_combined_cycle_coal_gas, full_load_hours),
  # ]
  SCALABLE_STEEL_KEYS = {
    input_industry_metal_steel_production: { nl2015: 6.99499999999998, nl: 6.65699999999998},
    input_industry_metal_steel_coal_demand: { nl2015: 2523.0499999999993, nl: 0.0},
    input_industry_metal_steel_cokes_demand: { nl2015: 3477.0099999999975, nl: 39.31405199999986},
    input_industry_metal_steel_coal_gas_demand: { nl2015: 27212.5699999999, nl: 27060.0838899999},
    input_industry_metal_steel_electricity_demand: { nl2015: 9782.9600000000, nl: 9186.5509560000},
    input_industry_metal_steel_network_gas_demand: { nl2015: 10755.84812153748, nl: 11317.021008723761},
    input_industry_metal_steel_steam_hot_water_demand: { nl2015: 1.0, nl: 9.880847999999965},
    input_industry_metal_steel_crude_oil_demand: { nl2015: 170.39999999999984, nl: 0.0},
    input_energy_cokesoven_transformation_coal_input_demand: { nl2015: 81858.27854509203, nl: 76336.12408611234},
    input_energy_blastfurnace_transformation_coal_input_demand: { nl2015: 40466.903111450236, nl: 42680.113603417434},
    input_energy_blastfurnace_transformation_cokes_input_demand: { nl2015: 51481.8801118137, nl: 53846.93722431166},
    input_energy_power_combined_cycle_coal_gas_coal_gas_input_demand: { nl2015: 17341.21999999998, nl: 14564.41182399992},
    input_energy_chp_coal_gas_coal_gas_input_demand: { nl2015: 8696.740000000002, nl: 8328.382559999955},
  }.freeze

  UNSCALABLE_STEEL_KEYS = {
    input_industry_steel_blastfurnace_bof_share: { nl2015: 0.9847033595425303, nl: 1.0},
    input_energy_cokesoven_transformation_cokes_output_conversion: { nl2015: 0.710233550857932, nl: 0.742153190678476},
    input_energy_cokesoven_transformation_coal_gas_output_conversion: { nl2015: 0.201181414633627, nl: 0.208175808393755},
    input_energy_blastfurnace_transformation_coal_gas_output_conversion: { nl2015: 0.400028846858287, nl: 0.352870450724913},
    input_energy_power_combined_cycle_coal_gas_electricity_output_conversion: { nl2015: 0.379281273174552, nl: 0.369384674988026},
    input_energy_chp_coal_gas_steam_hot_water_output_conversion: { nl2015: 0.0279415045177848, nl: 0.0259099135330786},
    input_energy_chp_coal_gas_electricity_output_conversion: { nl2015: 0.423469024025095, nl: 0.370279509350493},
    industry_final_demand_for_metal_steel_electricity_industry_steel_blastfurnace_bof_parent_share: { nl2015: 0.977068424256256, nl: 1.0},
    industry_final_demand_for_metal_steel_network_gas_industry_steel_blastfurnace_bof_parent_share: { nl2015: 0.98781761265, nl: 1.0},
    industry_final_demand_for_metal_steel_coal_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0},
    industry_final_demand_for_metal_steel_wood_pellets_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0},
    industry_final_demand_for_metal_steel_steam_hot_water_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0},
    industry_final_demand_for_metal_steel_crude_oil_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0},
    industry_final_demand_for_metal_steel_cokes_industry_steel_blastfurnace_bof_parent_share: { nl2015: 1.0, nl: 1.0},
    input_industry_other_cokes_non_energetic_demand: { nl2015: 0.0, nl: 0.0},
    input_industry_other_cokes_demand: { nl2015: 0.0, nl: 0.0},
    energy_chp_coal_gas_full_load_hours: { nl2015: 6354.38233269404, nl: 5320.0},
    energy_power_combined_cycle_coal_gas_full_load_hours: { nl2015: 2188.0, nl: 1789.0},

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

        year = is_2019?(dataset) ? :nl : :nl2015

        UNSCALABLE_STEEL_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year])
          end

        if factor == 0
          SCALABLE_STEEL_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        else
          SCALABLE_STEEL_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year] * factor)
          end
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
