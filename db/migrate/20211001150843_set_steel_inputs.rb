class SetSteelInputs < ActiveRecord::Migration[5.2]
  STEEL_KEYS = {
    input_industry_metal_steel_electricity_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_network_gas_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_coal_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_cokes_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_coal_gas_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_hydrogen_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_steam_hot_water_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_wood_pellets_demand: { nl2015: 100, nl: 200 },
    input_industry_metal_steel_crude_oil_demand: { nl2015: 100, nl: 200 }
  }.freeze

  def up
    say_with_time('Setting steel inputs for non nl datasets to zero') do
      counter = 0
      Dataset.where.not(country: :nl).each do |dataset|
        commit = dataset.commits.build(
          message: 'No data provided.',
          user: User.robot
        )
        STEEL_KEYS.each_key { |key| commit.dataset_edits.build(key: key, value: 0.0) }

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
        factor = dataset.editable_attributes.find(:input_industry_metal_steel_scaling_factor) || 0
        commit = dataset.commits.build(
          message: "Schatting Quintel op basis van emissiegegevens en Nederlandse energiebalans.
            URL: http://www.emissieregistratie.nl",
          user: User.robot
        )

        STEEL_KEYS.each do |key, values|
          base_value = is_2019?(dataset) ? values[:nl] : values[:nl2015]
          commit.dataset_edits.build(key: key, value: base_value * factor)
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
      STEEL_KEYS.each_key do |key|
        DatasetEdit.where(key: key).delete_all
      end
    end
  end
end
