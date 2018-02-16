class AssignDatasetsToRobot < ActiveRecord::Migration[5.0]
  def change
    user = User.robot

    unless group = Group.find_by(key: 'quintel')
      group = Group.create!(key: 'quintel')
    end

    user.group = group

    user.save


    Dataset.update_all(user_id: user.id)
  end
end
