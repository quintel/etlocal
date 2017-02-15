class DropUserIdFromSources < ActiveRecord::Migration[5.0]
  def change
    remove_column :sources, :user_id
  end
end
