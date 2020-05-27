class AddFullLoadHours < ActiveRecord::Migration[5.2]
  NL_FLHS = {
    'energy_power_wind_turbine_inland_full_load_hours' => 1920,
    'energy_power_wind_turbine_coastal_full_load_hours' => 2550,
    'energy_power_wind_turbine_offshore_full_load_hours' => 3500,
    'input_solar_panels_roofs_and_parks_full_load_hours' => 867,
    'energy_power_hydro_river_full_load_hours' => 2515,
    'energy_chp_local_engine_biogas_full_load_hours' => 8000,
    'energy_chp_local_wood_pellets_full_load_hours' => 6000,
    'energy_chp_supercritical_waste_mix_full_load_hours' => 5000,
    'energy_power_supercritical_waste_mix_full_load_hours' => 4100,
    'energy_power_combined_cycle_network_gas_full_load_hours' => 1950,
    'energy_power_ultra_supercritical_network_gas_full_load_hours' => 4600,
    'energy_power_turbine_network_gas_full_load_hours' => 7500,
    'energy_chp_local_engine_network_gas_full_load_hours' => 3361,
    'energy_chp_combined_cycle_network_gas_full_load_hours' => 3700,
    'energy_power_supercritical_coal_full_load_hours' => 5500,
    'energy_power_engine_diesel_full_load_hours' => 4000
  }.freeze
  BE_FLHS = {
    'energy_power_wind_turbine_inland_full_load_hours' => 2050,
    'energy_power_wind_turbine_coastal_full_load_hours' => 2850,
    'energy_power_wind_turbine_offshore_full_load_hours' => 3230,
    'input_solar_panels_roofs_and_parks_full_load_hours' => 890,
    'energy_power_hydro_river_full_load_hours' => 3330,
    'energy_chp_local_engine_biogas_full_load_hours' => 8000,
    'energy_chp_local_wood_pellets_full_load_hours' => 6000,
    'energy_chp_supercritical_waste_mix_full_load_hours' => 5100,
    'energy_power_supercritical_waste_mix_full_load_hours' => 4100,
    'energy_power_combined_cycle_network_gas_full_load_hours' => 850,
    'energy_power_ultra_supercritical_network_gas_full_load_hours' => 330,
    'energy_power_turbine_network_gas_full_load_hours' => 1800,
    'energy_chp_local_engine_network_gas_full_load_hours' => 3610,
    'energy_chp_combined_cycle_network_gas_full_load_hours' => 4900,
    'energy_power_supercritical_coal_full_load_hours' => 7500,
    'energy_power_engine_diesel_full_load_hours' => 4000
  }.freeze

  def self.up
    say "Checking and migrating #{Dataset.count} datasets"
    changed = 0

    Dataset.find_each do |dataset|
      if dataset.country == 'nl'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Gebaseerd op gemiddelde Nederlandse vollasturen (2015)'
          )

          NL_FLHS.each do |key, value|
            create_edit(com, key, value)
          end
        end

      elsif dataset.country == 'be'
        ActiveRecord::Base.transaction do
          com = Commit.create!(
            user_id: 4,
            dataset_id: dataset.id,
            message: 'Gebaseerd op gemiddelde Belgische vollasturen (2013)'
          )

          BE_FLHS.each do |key, value|
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
