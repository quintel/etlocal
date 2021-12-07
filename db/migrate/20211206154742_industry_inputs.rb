class IndustryInputs < ActiveRecord::Migration[5.2]

#Results of:
#[
#  V(industry_aluminium_production, demand)/BILLIONS,
#  V(industry_final_demand_for_metal_aluminium_electricity, demand)/MILLIONS,
#  V(industry_final_demand_for_metal_aluminium_network_gas, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_electricity, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_network_gas, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_steam_hot_water, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_wood_pellets, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_crude_oil, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_coal, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_network_gas_non_energetic, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_wood_pellets_non_energetic, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_crude_oil_non_energetic, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_fertilizers_coal_non_energetic, demand)/MILLIONS,
#  V(industry_useful_demand_for_chemical_refineries_crude_oil_non_energetic, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_electricity, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_network_gas, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_steam_hot_water, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_wood_pellets, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_coal, demand)/MILLIONS,
#  V(industry_final_demand_for_chemical_refineries_crude_oil, demand)/MILLIONS,
#  0.0,
#  0.0,
#  0.0,
#  V(EDGE(industry_refinery_transformation_crude_oil, energy_distribution_gasoline), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, industry_locally_available_crude_oil_non_energetic_for_chemical), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, energy_distribution_heavy_fuel_oil), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, energy_distribution_kerosene), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, energy_distribution_lpg), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, industry_locally_available_refinery_gas_for_chemical), demand)/MILLIONS,
#  V(EDGE(industry_refinery_transformation_crude_oil, energy_distribution_diesel), demand)/MILLIONS,
#  V(industry_refinery_transformation_crude_oil, output_of_loss)/MILLIONS,
#  V(EDGE(industry_aluminium_production, industry_aluminium_electrolysis_current_electricity), share),
#  V(EDGE(industry_aluminium_production, industry_aluminium_smeltoven_electricity), share),
#  V(EDGE(industry_final_demand_for_metal_aluminium_electricity, industry_aluminium_electrolysis_current_electricity), parent_share),
#  V(EDGE(industry_final_demand_for_metal_aluminium_electricity, industry_aluminium_smeltoven_electricity), parent_share),
#  V(EDGE(industry_aluminium_burner_network_gas, industry_aluminium_electrolysis_current_electricity), parent_share),
#  V(EDGE(industry_aluminium_burner_network_gas, industry_aluminium_smeltoven_electricity), parent_share),
#]
SCALABLE_ALUMINUM_KEYS = {
    input_industry_metal_aluminium_production: { nl2015: 0.0750000000000001, nl: 0.14999999999999916 },
    input_industry_metal_aluminium_electricity_demand: { nl2015: 3527.4000000000087, nl: 5797.4999999999745 },
    input_industry_metal_aluminium_network_gas_demand: { nl2015: 305.0000000000007, nl: 609.9999999999968 }
  }.freeze

  SCALABLE_FERTILIZER_KEYS = {
    input_industry_chemical_fertilizers_electricity_demand: { nl2015: 2700.000000000001, nl: 2999.999999999998 },
    input_industry_chemical_fertilizers_network_gas_demand: { nl2015: 23300.000000000015, nl: 22599.999999999993 },
    input_industry_chemical_fertilizers_steam_hot_water_demand: { nl2015: 0.0, nl: 5500.000000000008 },
    input_industry_chemical_fertilizers_wood_pellets_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_fertilizers_crude_oil_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_fertilizers_coal_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_fertilizers_network_gas_non_energetic_demand: { nl2015: 69400.00000000004, nl: 63900.00000000004 },
    input_industry_chemical_fertilizers_wood_pellets_non_energetic_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_fertilizers_crude_oil_non_energetic_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_fertilizers_coal_non_energetic_demand: { nl2015: 0.0, nl: 0.0 }
  }.freeze

  SCALABLE_REFINERIES_KEYS = {
    industry_useful_demand_for_chemical_refineries_crude_oil_non_energetic_demand: { nl2015: 2591264.8600000003, nl: 2650973.32178 },
    input_industry_chemical_refineries_electricity_demand: { nl2015: 9307.680000000004, nl: 10040.867499999991 },
    input_industry_chemical_refineries_network_gas_demand: { nl2015: 35888.079999999994, nl: 40001.69203000002 },
    input_industry_chemical_refineries_steam_hot_water_demand: { nl2015: 13490.41000000004, nl:10312.130269999978  },
    input_industry_chemical_refineries_wood_pellets_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_refineries_coal_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_refineries_crude_oil_demand: { nl2015: 100322.54000000008, nl: 100149.1771 },
    input_industry_chemical_refineries_network_gas_non_energetic_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_refineries_wood_pellets_non_energetic_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_chemical_refineries_coal_non_energetic_demand: { nl2015: 0.0, nl: 0.0 },
    input_industry_refinery_transformation_crude_oil_gasoline_demand: { nl2015: 241516.01999999996, nl: 175202.00507999994 },
    input_industry_refinery_transformation_crude_oil_other_oil_demand: { nl2015: 488107.8200000004, nl: 655051.6555140003 },
    input_industry_refinery_transformation_crude_oil_heavy_fuel_oil_demand: { nl2015: 350040.01000000106, nl: 365280.9248000003 },
    input_industry_refinery_transformation_crude_oil_kerosene_demand: { nl2015: 343784.9700000007, nl: 394143.5098299996 },
    input_industry_refinery_transformation_crude_oil_lpg_demand: { nl2015: 79810.00000000006, nl: 70763.99568999997 },
    input_industry_refinery_transformation_crude_oil_refinery_gas_demand: { nl2015: 112711.50000000006, nl: 103595.37399999988 },
    input_industry_refinery_transformation_crude_oil_diesel_demand: { nl2015: 952365.6199999999, nl: 887431.6578 },
    input_industry_refinery_transformation_crude_oil_loss_demand: { nl2015: 22928.919999998536, nl: 0.0 }
  }.freeze

  UNSCALABLE_INDUSTRY_KEYS = {
    input_industry_aluminium_electrolysis_current_electricity_share: { nl2015: 0.8000000000000003, nl: 0.6428571428571431 },
    input_industry_aluminium_smeltoven_electricity_share: { nl2015: 0.19999999999999982, nl: 0.357142857142857 },
    industry_final_demand_for_metal_aluminium_electricity_industry_aluminium_electrolysis_current_electricity_parent_share: { nl2015: 0.9814594318761695, nl: 0.9597116983921643 },
    industry_final_demand_for_metal_aluminium_electricity_industry_aluminium_smeltoven_electricity_parent_share: { nl2015: 0.018540568123830488, nl: 0.040288301607835704 },
    industry_aluminium_burner_network_gas_industry_aluminium_electrolysis_current_electricity_parent_share: { nl2015: 0.800000000000001, nl: 0.6428571428571442 },
    industry_aluminium_burner_network_gas_industry_aluminium_smeltoven_electricity_parent_share: { nl2015: 0.199999999999999, nl: 0.3571428571428558 }
  }.freeze

  def up
    say_with_time('Setting industry inputs for non nl datasets') do
      counter = 0
      Dataset.where.not(country: :nl).each do |dataset|
        commit = dataset.commits.build(
          message: 'No data provided.',
          user: User.robot
        )
        SCALABLE_ALUMINUM_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        SCALABLE_FERTILIZER_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        SCALABLE_REFINERIES_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        UNSCALABLE_INDUSTRY_KEYS.each { |key, values| commit.dataset_edits.build(key: key, value: values[:nl2015]) }

        commit.save!
        counter += 1
      end

      counter
    end

    say_with_time('Calculating and setting industry inputs for nl datasets') do
      counter = 0

      Dataset.where(country: :nl).each do |dataset|
        # NOTE: this scaling factor is now ususally empty. We save it with saying it's 0. Please
        # change that if you want other behaviour.
        factor_aluminum = dataset.editable_attributes.find("input_industry_metal_aluminium_scaling_factor").value || 0
        factor_fertilizer = dataset.editable_attributes.find("input_industry_chemical_fertilizers_scaling_factor").value || 0
        factor_refineries = dataset.editable_attributes.find("input_industry_chemical_refineries_scaling_factor").value || 0
        commit = dataset.commits.build(
          message: "Schatting Quintel op basis van emissiegegevens en Nederlandse energiebalans 2019.
            URL: http://www.emissieregistratie.nl",
          user: User.robot
        )

        year = is_2019?(dataset) ? :nl : :nl2015

        UNSCALABLE_INDUSTRY_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year])
          end

        if factor_aluminum == 0
          SCALABLE_ALUMINUM_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        else
          SCALABLE_ALUMINUM_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year] * factor_aluminum)
          end
        end

        if factor_fertilizer == 0
          SCALABLE_FERTILIZER_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        else
          SCALABLE_FERTILIZER_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year] * factor_fertilizer)
          end
        end

        if factor_fertilizer == 0
          SCALABLE_REFINERIES_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }
        else
          SCALABLE_REFINERIES_KEYS.each do |key, values|
            commit.dataset_edits.build(key: key, value: values[year] * factor_refineries)
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
    say_with_time('Removing all DatasetEdits for industry keys') do
      SCALABLE_ALUMINUM_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
      SCALABLE_FERTILIZER_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
      SCALABLE_REFINERIES_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
      UNSCALABLE_INDUSTRY_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
    end
  end
end
