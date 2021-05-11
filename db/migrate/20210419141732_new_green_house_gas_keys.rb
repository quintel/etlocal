class NewGreenHouseGasKeys < ActiveRecord::Migration[5.2]
  OLD_NEW_KEYS = {
    'other_emission_agriculture': 'non_energetic_emissions_other_ghg_agriculture_other',
    'other_emission_industry_energy': 'non_energetic_emissions_other_ghg_other_industry',
    'other_emission_transport': 'energetic_emissions_other_ghg_transport',
    'other_emission_built_environment': 'energetic_emissions_other_ghg_buildings'
  }.freeze

  OTHER_KEYS = [
    'non_energetic_emissions_co2_chemical_industry',
    'non_energetic_emissions_co2_other_industry',
    'non_energetic_emissions_co2_agriculture_manure',
    'non_energetic_emissions_co2_agriculture_soil_cultivation',
    'non_energetic_emissions_co2_waste_management',
    'indirect_emissions_co2',
    'energetic_emissions_other_ghg_industry',
    'energetic_emissions_other_ghg_energy',
    'energetic_emissions_other_ghg_households',
    'energetic_emissions_other_ghg_agriculture',
    'non_energetic_emissions_other_ghg_chemical_industry',
    'non_energetic_emissions_other_ghg_agriculture_fermentation',
    'non_energetic_emissions_other_ghg_agriculture_manure',
    'non_energetic_emissions_other_ghg_agriculture_soil_cultivation',
    'non_energetic_emissions_other_ghg_waste_management'
  ].freeze

  def self.up
    # The 4 greenhouse gas attributes will be replaced by 19 attributes
    # adding more detail to the non-energetic greenhouse gas emissions of
    # a region. In this migration, the 4 'old' keys are mapped to their
    # closest counterpart of the 19 new keys. The other keys are set to zero.

    OLD_NEW_KEYS.each_pair do |old_key, new_key|
      DatasetEdit.where(key: old_key).update_all(key: new_key)
    end

    Dataset.find_each do |dataset|
      ActiveRecord::Base.transaction do
        com = Commit.create!(
          user_id: 4,
          dataset_id: dataset.id,
          message: 'New attribute (added to ETM in April 2021). Set to zero.'
        )

        OTHER_KEYS.each do |key|
          create_edit(com, key, 0.0)
        end
      end
    end
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
