class AddFlhDefaults < ActiveRecord::Migration[5.2]
  COUNTRIES = %w[AT BE BG CY CZ DE DK EE ES FI FR UK EL HR HU IE IT LT LU LV NL PL
    PT RO SE SI SK]


  DEFAULTS = {
    energy_power_ultra_supercritical_coal_full_load_hours: 5440,
    energy_power_supercritical_coal_full_load_hours: 5000,
    energy_power_ultra_supercritical_lignite_full_load_hours: 7500,
    energy_power_ultra_supercritical_network_gas_full_load_hours: 4000,
    energy_power_turbine_network_gas_full_load_hours: 4000,
    energy_power_combined_cycle_network_gas_full_load_hours: 4000,
    energy_power_ultra_supercritical_crude_oil_full_load_hours: 4000,
    energy_power_nuclear_gen2_uranium_oxide_full_load_hours: 7630,
    energy_power_supercritical_waste_mix_full_load_hours: 4100,
    energy_power_hydro_river_full_load_hours: 2005,
    energy_power_hydro_mountain_full_load_hours: 4024,
    energy_power_geothermal_full_load_hours: 8000
  }.freeze

  def up
    Dataset.where(geo_id: COUNTRIES).each do |dataset|
      change = false
      commit = dataset.commits.build(
        message: 'No installed capacity for this type of power plant, full load hours are set to default; year: 2019',
        user: User.robot
      )

      DEFAULTS.each do |key, default_value|
        if dataset.editable_attributes.find(key.to_s).value.zero?
          commit.dataset_edits.build(key: key, value: default_value)
          change = true
        end
      end

      commit.save! if change
    end
  end
end
