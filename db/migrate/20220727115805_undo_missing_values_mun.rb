class UndoMissingValuesMun < ActiveRecord::Migration[5.2]
  EXPECTED_VALUES = {
    'energy_distribution_network_gas_loss_demand' => 0.0,
    'industry_final_demand_for_metal_steel_coal_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_cokes_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_crude_oil_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_electricity_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_network_gas_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_steam_hot_water_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'industry_final_demand_for_metal_steel_wood_pellets_industry_steel_scrap_hbi_eaf_parent_share' => 0.0,
    'input_energy_blastfurnace_transformation_loss_output_conversion' => 0.0,
    'input_energy_chp_coal_gas_loss_output_conversion' => 0.0,
    'input_energy_cokesoven_transformation_loss_output_conversion' => 0.0,
    'input_energy_power_combined_cycle_coal_gas_loss_output_conversion' => 0.0,
    'input_energy_power_supercritical_ccs_waste_mix_electricity_output_conversion' => 27.0,
    'input_industry_steel_scrap_hbi_eaf_share' => 0.0
  }.freeze

  def up
    geo_ids = CSV
      .table(Rails.root.join('db/migrate/20220725161945_missing_values_mun/data.csv'))
      .map(&:first).map(&:last)

    Dataset.transaction do
      Dataset.where(geo_id: geo_ids).each do |dataset|
        commit = find_commit(dataset)

        raise("#{dataset.geo_id}: no matching commit found") unless commit

        commit.destroy!
        say("#{dataset.geo_id}: matching commit removed")
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def find_commit(dataset)
    # Search the last five commits.
    dataset.commits.includes(:dataset_edits).order(created_at: :desc).limit(5).find do |commit|
      next if commit.message != 'Set to NL data.'

      commit.dataset_edits.all? do |edit|
        EXPECTED_VALUES[edit.key] == edit.value
      end
    end
  end
end
