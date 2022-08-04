# Clone an existing dataset and set it as the Panama dataset in order to start this
# new dataset with some base values in place.

class SetupPanama < ActiveRecord::Migration[5.2]
  BASE_DATASET_GEO = :UKNI01
  NEW_GEO_ID = :RGPA01
  NEW_NAME = 'Panama - Ports of Cristobal and Balboa'.freeze

  TO_ZERO = %w[
    agriculture_final_demand_electricity_demand
    agriculture_final_demand_network_gas_demand
    agriculture_final_demand_steam_hot_water_demand
    agriculture_final_demand_wood_pellets_demand
    input_agriculture_final_demand_crude_oil_demand
    agriculture_final_demand_hydrogen_demand
    buildings_final_demand_electricity_buildings_final_demand_for_lighting_electricity_parent_share
    buildings_final_demand_electricity_buildings_final_demand_for_space_heating_electricity_parent_share
    buildings_final_demand_electricity_buildings_final_demand_for_appliances_electricity_parent_share
    buildings_final_demand_electricity_buildings_final_demand_for_cooling_electricity_parent_share
    buildings_final_demand_for_lighting_electricity_buildings_lighting_efficient_fluorescent_electricity_parent_share
    buildings_final_demand_for_lighting_electricity_buildings_lighting_standard_fluorescent_electricity_parent_share
    buildings_final_demand_for_lighting_electricity_buildings_lighting_led_electricity_parent_share
    buildings_final_demand_for_cooling_electricity_buildings_cooling_airconditioning_electricity_parent_share
    buildings_final_demand_for_cooling_electricity_buildings_cooling_heatpump_air_water_electricity_parent_share
    buildings_final_demand_for_cooling_electricity_buildings_cooling_collective_heatpump_water_water_ts_electricity_parent_share
    input_buildings_solar_pv_demand
    buildings_final_demand_solar_thermal_demand
    input_buildings_electricity_demand
    buildings_final_demand_network_gas_demand
    buildings_final_demand_steam_hot_water_demand
    buildings_final_demand_wood_pellets_demand
    buildings_final_demand_coal_demand
    input_buildings_final_demand_crude_oil_demand
    buildings_final_demand_solar_thermal_demand
    number_of_buildings
    buildings_roof_surface_available_for_pv
    input_buildings_heat_demand_reduction
    input_transport_ship_diesel_demand
    input_transport_ship_biodiesel_demand
    transport_final_demand_for_shipping_lng_demand
    transport_final_demand_for_shipping_bio_lng_demand
    transport_final_demand_heavy_fuel_oil_demand
    bunkers_total_useful_demand_ships_demand
    input_transport_rail_electricity_demand
    input_transport_rail_diesel_demand
    input_transport_rail_biodiesel_demand
    transport_final_demand_coal_demand
    transport_final_demand_kerosene_demand
    input_transport_plane_gasoline_demand
    input_transport_plane_bio_ethanol_demand
    bunkers_total_useful_demand_planes_demand
    number_of_cars
    input_transport_road_human_powered_bicycle_demand
    input_transport_road_gasoline_demand
    input_transport_road_diesel_demand
    transport_final_demand_lpg_demand
    input_transport_road_electricity_demand
    input_transport_road_bio_ethanol_demand
    input_transport_road_biodiesel_demand
    transport_final_demand_for_road_compressed_network_gas_demand
    transport_final_demand_hydrogen_demand
    transport_final_demand_for_road_lng_demand
    transport_final_demand_for_road_bio_lng_demand
    transport_road_mixer_gasoline_transport_car_using_gasoline_mix_parent_share
    transport_road_mixer_gasoline_transport_van_using_gasoline_mix_parent_share
    transport_road_mixer_gasoline_transport_bus_using_gasoline_mix_parent_share
    transport_road_mixer_gasoline_transport_truck_using_gasoline_mix_parent_share
    transport_road_mixer_gasoline_transport_motorcycle_using_gasoline_mix_parent_share
    transport_road_mixer_diesel_transport_car_using_diesel_mix_parent_share
    transport_road_mixer_diesel_transport_van_using_diesel_mix_parent_share
    transport_road_mixer_diesel_transport_bus_using_diesel_mix_parent_share
    transport_road_mixer_diesel_transport_truck_using_diesel_mix_parent_share
    co2_emission_1990
    co2_emission_1990_aviation_bunkers
    co2_emission_1990_marine_bunkers
    energetic_emissions_other_ghg_households
    energetic_emissions_other_ghg_buildings
    energetic_emissions_other_ghg_transport
    energetic_emissions_other_ghg_agriculture
    energetic_emissions_other_ghg_industry
    energetic_emissions_other_ghg_energy
    non_energetic_emissions_co2_chemical_industry
    non_energetic_emissions_co2_waste_management
    non_energetic_emissions_co2_other_industry
    non_energetic_emissions_co2_agriculture_manure
    non_energetic_emissions_co2_agriculture_soil_cultivation
    indirect_emissions_co2
    non_energetic_emissions_other_ghg_chemical_industry
    non_energetic_emissions_other_ghg_waste_management
    non_energetic_emissions_other_ghg_other_industry
    non_energetic_emissions_other_ghg_agriculture_manure
    non_energetic_emissions_other_ghg_agriculture_soil_cultivation
    non_energetic_emissions_other_ghg_agriculture_fermentation
    non_energetic_emissions_other_ghg_agriculture_other
    total_land_area
    areable_land
    offshore_suitable_for_wind
    coast_line
    analysis_year
    energy_extraction_coal_demand
    energy_extraction_lignite_demand
    energy_extraction_crude_oil_demand
    energy_extraction_natural_gas_demand
    energy_extraction_uranium_oxide_demand
    energy_power_sector_own_use_electricity_demand
    energy_power_hv_network_loss_demand
    energy_distribution_greengas_demand
    energy_regasification_lng_energy_national_gas_network_natural_gas_demand
    energy_distribution_network_gas_loss_demand
    input_energy_power_ultra_supercritical_coal_production
    input_energy_power_supercritical_coal_production
    input_energy_power_combined_cycle_coal_production
    input_energy_power_ultra_supercritical_cofiring_coal_production
    input_energy_power_combined_cycle_ccs_coal_production
    input_energy_power_ultra_supercritical_ccs_coal_production
    input_energy_chp_ultra_supercritical_coal_production
    input_energy_chp_ultra_supercritical_cofiring_coal_production
    input_energy_power_ultra_supercritical_lignite_production
    input_energy_chp_ultra_supercritical_lignite_production
    input_energy_power_ultra_supercritical_oxyfuel_ccs_lignite_production
    input_energy_power_ultra_supercritical_network_gas_production
    input_energy_power_turbine_network_gas_production
    input_energy_power_engine_network_gas_production
    input_energy_power_combined_cycle_network_gas_production
    input_energy_power_combined_cycle_ccs_network_gas_production
    input_energy_chp_combined_cycle_network_gas_production
    input_energy_chp_local_engine_network_gas_production
    input_energy_power_nuclear_gen2_uranium_oxide_production
    input_energy_power_nuclear_gen3_uranium_oxide_production
    input_energy_power_ultra_supercritical_crude_oil_production
    input_energy_power_engine_diesel_production
    input_energy_heat_burner_wood_pellets_production
    input_energy_heat_well_geothermal_production
    input_energy_heat_burner_waste_mix_production
    input_energy_heat_burner_hydrogen_production
    input_energy_heat_solar_thermal_production
    input_energy_heat_heatpump_water_water_electricity_production
    input_energy_heat_burner_network_gas_production
    input_energy_heat_burner_coal_production
    input_energy_heat_burner_crude_oil_production
    energy_import_heat_demand
    energy_heat_distribution_loss_demand
    input_energy_power_wind_turbine_inland_production
    input_energy_power_wind_turbine_coastal_production
    input_energy_power_wind_turbine_offshore_production
    input_energy_power_solar_pv_solar_radiation_production
    input_energy_power_solar_csp_solar_radiation_production
    input_energy_power_supercritical_waste_mix_production
    input_energy_chp_supercritical_waste_mix_production
    input_energy_power_supercritical_ccs_waste_mix_production
    input_energy_chp_local_wood_pellets_production
    input_energy_chp_local_engine_biogas_production
    input_energy_power_hydro_river_production
    input_energy_power_hydro_mountain_production
    input_energy_power_geothermal_production
    energy_production_dry_biomass_max_demand
    energy_production_wet_biomass_max_demand
    energy_production_oily_biomass_max_demand
    other_final_demand_electricity_demand
    other_final_demand_network_gas_demand
    other_final_demand_steam_hot_water_demand
    other_final_demand_wood_pellets_demand
    other_final_demand_coal_demand
    other_final_demand_crude_oil_demand
    other_final_demand_crude_oil_non_energetic_demand
    number_of_residences
    residences_roof_surface_available_for_pv
    input_households_solar_pv_demand
    households_final_demand_solar_thermal_demand
    households_final_demand_electricity_demand
    households_final_demand_network_gas_demand
    households_final_demand_steam_hot_water_demand
    households_final_demand_wood_pellets_demand
    households_final_demand_coal_demand
    input_households_final_demand_crude_oil_demand
    households_final_demand_solar_thermal_demand
    input_transport_rail_diesel_demand
    input_transport_rail_diesel_demand
    input_industry_metal_aluminium_production
    input_industry_metal_aluminium_electricity_demand
    input_industry_metal_aluminium_network_gas_demand
    input_industry_metal_steel_production
    input_industry_metal_steel_coal_demand
    input_industry_metal_steel_cokes_demand
    input_industry_metal_steel_coal_gas_demand
    input_industry_metal_steel_electricity_demand
    input_industry_metal_steel_network_gas_demand
    input_industry_metal_steel_steam_hot_water_demand
    input_industry_metal_steel_crude_oil_demand
    input_industry_metal_steel_wood_pellets_demand
    input_energy_cokesoven_transformation_coal_input_demand
    input_energy_blastfurnace_transformation_coal_input_demand
    input_energy_blastfurnace_transformation_cokes_input_demand
    input_energy_power_combined_cycle_coal_gas_coal_gas_input_demand
    input_energy_chp_coal_gas_coal_gas_input_demand
    industry_chp_combined_cycle_gas_power_fuelmix_demand
    industry_chp_engine_gas_power_fuelmix_demand
    industry_chp_turbine_gas_power_fuelmix_demand
    industry_chp_ultra_supercritical_coal_demand
    industry_chp_wood_pellets_demand
    industry_heat_burner_lignite_demand
    industry_heat_burner_coal_demand
    industry_heat_well_geothermal_demand
    industry_heat_burner_crude_oil_demand
    input_industry_food_electricity_demand
    input_industry_food_network_gas_demand
    input_industry_food_steam_hot_water_demand
    input_industry_food_wood_pellets_demand
    input_industry_food_crude_oil_demand
    input_industry_food_coal_demand
    input_industry_other_electricity_demand
    input_industry_other_network_gas_demand
    input_industry_other_steam_hot_water_demand
    input_industry_other_wood_pellets_demand
    input_industry_other_crude_oil_demand
    input_industry_other_coal_demand
    input_industry_other_cokes_demand
    input_industry_other_network_gas_non_energetic_demand
    input_industry_other_wood_pellets_non_energetic_demand
    input_industry_other_crude_oil_non_energetic_demand
    input_industry_other_coal_non_energetic_demand
    input_industry_other_cokes_non_energetic_demand
    input_industry_ict_electricity_demand
    industry_useful_demand_for_chemical_refineries_crude_oil_non_energetic_demand
    input_industry_chemical_refineries_wood_pellets_non_energetic_demand
    input_industry_chemical_refineries_network_gas_non_energetic_demand
    input_industry_chemical_refineries_coal_non_energetic_demand
    input_industry_chemical_refineries_electricity_demand
    input_industry_chemical_refineries_network_gas_demand
    input_industry_chemical_refineries_steam_hot_water_demand
    input_industry_chemical_refineries_wood_pellets_demand
    input_industry_chemical_refineries_coal_demand
    input_industry_chemical_refineries_crude_oil_demand
    input_industry_refinery_transformation_crude_oil_other_oil_demand
    input_industry_refinery_transformation_crude_oil_gasoline_demand
    input_industry_refinery_transformation_crude_oil_heavy_fuel_oil_demand
    input_industry_refinery_transformation_crude_oil_kerosene_demand
    input_industry_refinery_transformation_crude_oil_lpg_demand
    input_industry_refinery_transformation_crude_oil_refinery_gas_demand
    input_industry_refinery_transformation_crude_oil_diesel_demand
    energy_distribution_crude_oil_loss_demand
    input_industry_metal_other_electricity_demand
    input_industry_metal_other_network_gas_demand
    input_industry_metal_other_steam_hot_water_demand
    input_industry_metal_other_crude_oil_demand
    input_industry_metal_other_coal_demand
    input_industry_chemical_fertilizers_electricity_demand
    input_industry_chemical_fertilizers_network_gas_demand
    input_industry_chemical_fertilizers_steam_hot_water_demand
    input_industry_chemical_fertilizers_wood_pellets_demand
    input_industry_chemical_fertilizers_crude_oil_demand
    input_industry_chemical_fertilizers_coal_demand
    input_industry_chemical_fertilizers_network_gas_non_energetic_demand
    input_industry_chemical_fertilizers_wood_pellets_non_energetic_demand
    input_industry_chemical_fertilizers_crude_oil_non_energetic_demand
    input_industry_chemical_fertilizers_coal_non_energetic_demand
    input_industry_chemical_fertilizers_hydrogen_non_energetic_demand
    input_industry_chemical_other_electricity_demand
    input_industry_chemical_other_network_gas_demand
    input_industry_chemical_other_steam_hot_water_demand
    input_industry_chemical_other_wood_pellets_demand
    input_industry_chemical_other_crude_oil_demand
    input_industry_chemical_other_coal_demand
    input_industry_chemical_other_network_gas_non_energetic_demand
    input_industry_chemical_other_wood_pellets_non_energetic_demand
    input_industry_chemical_other_crude_oil_non_energetic_demand
    input_industry_chemical_other_coal_non_energetic_demand
    input_industry_paper_electricity_demand
    input_industry_paper_network_gas_demand
    input_industry_paper_steam_hot_water_demand
    input_industry_paper_wood_pellets_demand
    input_industry_paper_crude_oil_demand
    input_industry_paper_coal_demand
  ].freeze

  def up
    clone = DatasetCloner.clone!(Dataset.find_by(geo_id: BASE_DATASET_GEO), User.robot)

    destroy_invalid_history(clone)

    clone.update!(
      geo_id: NEW_GEO_ID,
      name: NEW_NAME,
      public: true,
      data_source: 'db'
    )

    inputs_to_zero(clone)
  end

  def down
    Dataset.find_by(geo_id: NEW_GEO_ID).destroy!
  end

  private

  # Removes the commit history and sets the input to zero
  def inputs_to_zero(dataset)
    commit = dataset.commits.build(
      message: 'Initialise new dataset with 0.',
      user: User.robot
    )

    TO_ZERO.each do |input_key|
      destroy_edits(dataset, input_key)
      commit.dataset_edits.build(key: input_key, value: 0.0)
    end

    commit.save!
  end

  # Finds all commits belonging to a dataset with an edit to the given key.
  def find_commits(dataset, edit_key)
    dataset.commits
      .joins(:dataset_edits)
      .where(dataset_edits: { key: edit_key })
      .order(updated_at: :desc)
  end

  # Removes all dataset edits matching the `edit_key`. If the key is the only
  # dataset belonging to the commit, the commit will also be removed.
  def destroy_edits(dataset, edit_key)
    commits = find_commits(dataset, edit_key)

    return if commits.none?

    commits.each do |commit|
      if commit.dataset_edits.one?
        commit.destroy
      else
        commit.dataset_edits.find_by(key: edit_key).destroy
      end
    end
  end

  # Checks if all commits are still valid, and destroys the old ones that are not
  # Over time some inputs have been replaced by others, but edits on these old
  # inputs may have perstisted in the dataset that served as a base
  def destroy_invalid_history(dataset)
    return if dataset.valid?

    dataset.commits.each do |commit|
      next if commit.valid?

      if commit.dataset_edits.one?
        commit.destroy
      else
        commit.dataset_edits.each do |edit|
          edit.destroy unless edit.valid?
        end
      end
    end
  end
end
