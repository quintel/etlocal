class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :key
      t.timestamps
    end

    add_reference :users, :group, after: :id
    add_reference :datasets, :user, after: :id
  end
end
