class AddOilMixSliders < ActiveRecord::Migration[5.2]
  SECTORS = %w[industry households buildings agriculture].freeze
  OIL_CARRIERS = %w[diesel biodiesel kerosene bio_kerosene lpg bio_oil].freeze

  def up
    say_with_time('Adding oil mix sliders') do
      length = Dataset.all.count

      Dataset.find_each.with_index do |dataset, index|
        # Set input for all oil mixes
        commit = dataset.commits.build(
          message: 'Geen data beschikbaar. Nieuwe sliders in het ETM (augustus 2021).',
          user: User.robot
        )

        SECTORS.each do |sector|
          OIL_CARRIERS.each do |carrier|
            commit.dataset_edits.build(
              key: "input_percentage_of_#{carrier}_#{sector}_final_demand_crude_oil".to_sym,
              value: 0.0
            )
          end
          commit.dataset_edits.build(
            key: "input_percentage_of_crude_oil_#{sector}_final_demand_crude_oil".to_sym,
            value: 1.0
          )
        end

        commit.save!

        say("#{index}/#{length}") if (index % 100).zero?
      end

      # Rename old sliders
      SECTORS.each do |sector|
        next if sector == 'industry'

        DatasetEdit.where(
          key: "#{sector}_final_demand_crude_oil_demand"
        ).update_all(
          key: "input_#{sector}_final_demand_crude_oil_demand"
        )
      end
    end
  end

  def down
    say_with_time('Removing oil mix sliders') do
      SECTORS.each do |sector|
        OIL_CARRIERS.each do |carrier|
          DatasetEdit.where(key: "input_percentage_of_#{carrier}_#{sector}_final_demand_crude_oil").delete_all
        end
        DatasetEdit.where(key: "input_percentage_of_crude_oil_#{sector}_final_demand_crude_oil").delete_all

        DatasetEdit.where(
          key: "input_#{sector}_final_demand_crude_oil_demand"
        ).update_all(
          key: "#{sector}_final_demand_crude_oil_demand"
        )
      end
    end
  end
end
