class RemoveEmptyDatasets < ActiveRecord::Migration[5.0]
  def up
    raise 'Could not find Robot user' unless User.robot

    execute <<~SQL
      DELETE FROM datasets
      WHERE
        user_id = #{User.robot.id} AND
        id NOT IN (SELECT dataset_id FROM commits)
    SQL
  end

  def down
    ActiveRecord::IrreversibleMigration
  end
end
