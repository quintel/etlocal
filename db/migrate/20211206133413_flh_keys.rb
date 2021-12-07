class FlhKeys < ActiveRecord::Migration[5.2]

  COMMITS = [
    {
      message: 'Based on average full load hours of the Netherlands (2019) as default. These full load hours will change in the future year due to the electricity merit order.',
      sliders: {
        'energy_power_engine_network_gas_full_load_hours' => 1.0,
        'energy_power_ultra_supercritical_ccs_coal_full_load_hours' => 7500.0,
        'energy_power_ultra_supercritical_coal_full_load_hours' => 7100.0,
        'energy_power_ultra_supercritical_cofiring_coal_full_load_hours' => 7100.0,
        'energy_power_ultra_supercritical_lignite_full_load_hours' => 6329.0,
        'energy_power_ultra_supercritical_oxyfuel_ccs_lignite_full_load_hours' => 5972.0,
        'energy_power_ultra_supercritical_crude_oil_full_load_hours' => 4000.0,
        'energy_power_nuclear_gen2_uranium_oxide_full_load_hours' => 8000.0,
        'energy_power_nuclear_gen3_uranium_oxide_full_load_hours' => 7800.0,
        'energy_power_geothermal_full_load_hours' => 8000.0,
        'energy_power_hydro_mountain_full_load_hours' => 4024.0,
        'energy_power_supercritical_ccs_waste_mix_full_load_hours' => 4100.0,
        'flh_solar_pv_solar_radiation_max' => 1361.3,
        'industry_chp_turbine_gas_power_fuelmix_full_load_hours' => 3200.0,
        'industry_chp_engine_gas_power_fuelmix_full_load_hours' => 1300.0,
        'industry_chp_combined_cycle_gas_power_fuelmix_full_load_hours' => 2959.9,
        'energy_chp_ultra_supercritical_cofiring_coal_full_load_hours' => 8000.0,
        'energy_chp_ultra_supercritical_coal_full_load_hours' => 8000.0,
        'energy_chp_ultra_supercritical_lignite_full_load_hours' => 4500.0,
        'industry_chp_ultra_supercritical_coal_full_load_hours' => 4500.0,
        'industry_chp_wood_pellets_full_load_hours' => 6000.0,
        'energy_heat_burner_coal_full_load_hours' => 2190.0,
        'industry_heat_burner_coal_full_load_hours' => 2190.0,
        'industry_heat_burner_crude_oil_full_load_hours' => 2190.0,
        'energy_heat_burner_crude_oil_full_load_hours' => 2190.0,
        'energy_heat_burner_network_gas_full_load_hours' => 2190.0,
        'industry_heat_burner_lignite_full_load_hours' => 2190.0,
        'energy_heat_burner_wood_pellets_full_load_hours' => 2190.0,
        'energy_heat_burner_waste_mix_full_load_hours' => 2190.0,
        'energy_heat_heatpump_water_water_electricity_full_load_hours' => 6500.0,
        'energy_chp_coal_gas_full_load_hours' => 6354.3,
        'energy_power_combined_cycle_coal_gas_full_load_hours' => 2188.0
      }
    },
    {
      message: 'No solar csp plants in start year',
      sliders: {
        'input_energy_power_solar_csp_solar_radiation_production' => 0.0
      }
    }
  ].freeze

  NL_FLHS = {
    'energy_heat_solar_thermal_full_load_hours' => 684.0
  }.freeze

  BE_FLHS = {
    'energy_heat_solar_thermal_full_load_hours' => 687.0
  }.freeze

  DE_FLHS = {
    'energy_heat_solar_thermal_full_load_hours' => 749.0
  }.freeze

  UK_FLHS = {
    'energy_heat_solar_thermal_full_load_hours' => 609.0
  }.freeze

  def up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each do |dataset|
      COMMITS.each do |commit|
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user: User.robot,
            dataset_id: dataset.id,
            message: commit[:message]
          )

          commit[:sliders].each do |key, value|
            create_edit(com, key, value)
          end
        end
      end
    changed += 1
    end

    Dataset.find_each do |dataset|
      if dataset.country == 'nl'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on average full load hours of the Netherlands (2019)'
          )

          NL_FLHS.each do |key, value|
            create_edit(com, key, value)
          end
        end

      if dataset.country == 'be'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on average full load hours of Belgium (2013)'
          )

          BE_FLHS.each do |key, value|
            create_edit(com, key, value)
          end
        end
      end

      if dataset.country == 'de'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on average full load hours of Germany (2015)'
          )

          DE_FLHS.each do |key, value|
            create_edit(com, key, value)
          end
        end
      end

      elsif dataset.country == 'uk'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Based on average full load hours of the United Kingdom (2012)'
          )

          UK_FLHS.each do |key, value|
            create_edit(com, key, value)
          end
        end
      end
      changed += 1
    end


    say "Finished (#{changed} updated)"
  end

  private

  # Create a new dataset edit
  def create_edit(commit, key, value)
    ActiveRecord::Base.transaction do
      DatasetEdit.create!(
        commit_id: commit.id,
        key: key,
        value: value
      )
    end
  end
end
