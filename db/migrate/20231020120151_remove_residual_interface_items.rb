class RemoveResidualInterfaceItems < ActiveRecord::Migration[7.0]
  # Keys to remove
  KEYS_TO_REMOVE = %w[
    industry_useful_demand_for_chemical_other_useable_heat_industry_chemicals_other_processes_potential_residual_heat_parent_share
    industry_useful_demand_for_chemical_other_useable_heat_industry_chemicals_other_flue_gasses_potential_residual_heat_parent_share
    industry_useful_demand_for_chemical_other_useable_heat_industry_chemicals_other_used_heat_parent_share
    industry_useful_demand_for_chemical_refineries_useable_heat_industry_chemicals_refineries_processes_potential_residual_heat_parent_share
    industry_useful_demand_for_chemical_refineries_useable_heat_industry_chemicals_refineries_flue_gasses_potential_residual_heat_parent_share
    industry_useful_demand_for_chemical_refineries_useable_heat_industry_chemicals_refineries_used_heat_parent_share
    industry_chemicals_fertilizers_production_industry_chemicals_fertilizers_processes_potential_residual_heat_parent_share
    industry_chemicals_fertilizers_production_industry_chemicals_fertilizers_flue_gasses_potential_residual_heat_parent_share
    industry_chemicals_fertilizers_production_industry_chemicals_fertilizers_used_heat_parent_share
    industry_useful_demand_for_other_ict_electricity_industry_other_ict_potential_residual_heat_from_servers_electricity_parent_share
    industry_useful_demand_for_other_ict_electricity_industry_other_ict_other_systems_electricity_parent_share
  ].freeze

  def self.up
    # First remove the DatasetEdits for the given keys
    DatasetEdit.where(key: KEYS_TO_REMOVE).in_batches.destroy_all

    # Then remove the commits that no longer have any DatasetEdits associated with them
    Commit.where.missing(:dataset_edits).in_batches.destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
