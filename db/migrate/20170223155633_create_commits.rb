class CreateCommits < ActiveRecord::Migration[5.0]
  def change
    create_table :commits do |t|
      t.belongs_to(:source)
      t.belongs_to(:user)
      t.text :message
      t.timestamps
    end
  end
end
