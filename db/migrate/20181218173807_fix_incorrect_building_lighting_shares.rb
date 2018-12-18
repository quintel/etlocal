class FixIncorrectBuildingLightingShares < ActiveRecord::Migration[5.0]
  CHANGES = {
    buildings_final_demand_for_lighting_electricity_buildings_lighting_standard_fluorescent_electricity_parent_share: [0.05, 0.94],
    buildings_final_demand_for_lighting_electricity_buildings_lighting_efficient_fluorescent_electricity_parent_share: [0.94, 0.05]
  }.freeze

  def up
    ActiveRecord::Base.transaction do
      CHANGES.each do |key, (from, to)|
        update_attribute(key, from, to)
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      CHANGES.each do |key, (to, from)|
        update_attribute(key, from, to)
      end
    end
  end

  private

  def update_attribute(name, from, to)
    edits = DatasetEdit
      .joins(:commit)
      .where(
        key: name, value: from, commits: {
          message: 'Standaardwaarden op basis van Nederlandse gemiddelden'
        }
      )

    say_with_time "Updating #{name} from #{from} to #{to}" do
      edits.update_all(value: to)
    end
  end
end
