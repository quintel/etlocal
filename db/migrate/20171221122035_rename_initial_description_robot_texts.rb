class RenameInitialDescriptionRobotTexts < ActiveRecord::Migration[5.0]
  def change
    Commit.where(user: User.robot).update_all(message: "Initial value by Quintel as stated by <a href='https://www.cbs.nl'>CBS</a>");
  end
end
