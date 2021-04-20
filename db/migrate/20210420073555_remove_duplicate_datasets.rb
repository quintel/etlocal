class RemoveDuplicateDatasets < ActiveRecord::Migration[5.2]
  NEW_IDS_FOR_CLONES = {
    RGAMS01: { geo_id: :GM0363, id: 18_511 },
    RGGLD01: { geo_id: :PV25_plus }
  }.freeze

  def up
    NEW_IDS_FOR_CLONES.each do |new_id, old_info|
      Dataset.find_by(**old_info)&.update(geo_id: new_id, user: robot)
    end

    remove_all_clones
  end

  def down
    NEW_IDS_FOR_CLONES.each do |new_id, old_info|
      Dataset.find_by(geo_id: new_id)&.update(geo_id: old_info[:geo_id])
    end
  end

  private

  def remove_all_clones
    Dataset.all.each do |dataset|
      Dataset.clones(dataset, robot).reject { |d| d.user == robot }.each(&:destroy)
    end
  end

  def robot
    @robot ||= User.robot
  end
end
