class NeighborhoodRegionProvinceVanSplit < ActiveRecord::Migration[5.0]
  # Create the same commit with the same values for all regions, provinces and neighbourhoods
  GROUPS = %w[neighbourhood region res province].freeze

  MSG_VANS = 'Geen data beschikbaar. Aanname is daarom dat het aandeel bestelbussen 0 is.'
  VANS = {
    transport_road_mixer_gasoline_transport_van_using_gasoline_mix_parent_share: 0.0,
    transport_road_mixer_diesel_transport_van_using_diesel_mix_parent_share: 0.0,
    transport_road_mixer_compressed_network_gas_transport_van_using_compressed_natural_gas_parent_share: 0.0,
    transport_final_demand_for_road_lpg_transport_van_using_lpg_parent_share: 0.0,
    transport_final_demand_for_road_electricity_transport_van_using_electricity_parent_share: 0.0,
    transport_final_demand_for_road_hydrogen_transport_van_using_hydrogen_parent_share: 0.0
  }.freeze

  MSG_CARS = "Geen data beschikbaar. Aanname is daarom dat het aandeel van auto's 100% is.".freeze
  CARS_KEY = 'transport_final_demand_for_road_lpg_transport_car_using_lpg_parent_share'.freeze
  CARS_VAL = 1.0

  def self.up
    Dataset.all.select{ |d| GROUPS.include? d.group }.each do |dataset|
      create_commits(dataset)
    end
  end

  # def self.down
  #   raise ActiveRecord::IrreversibleMigration
  # end

  def create_commits(dataset)
    commit_vans = build_vans_commit(dataset)
    commit_vans.save!

    commit_cars = build_cars_commit(dataset)
    commit_cars.save!
  end

  def build_cars_commit(dataset)
    commit = Commit.new(dataset: dataset, message: MSG_CARS, user: User.robot)
    commit.dataset_edits.build(key: CARS_KEY, value: CARS_VAL)

    commit
  end

  def build_vans_commit(dataset)
    commit = Commit.new(dataset: dataset, message: MSG_VANS, user: User.robot)
    VANS.each { |key, value| commit.dataset_edits.build(key: key, value: value) }

    commit
  end
end
