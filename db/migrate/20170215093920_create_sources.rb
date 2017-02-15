class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.belongs_to(:user)
      t.timestamps
    end

    add_attachment :sources, :source_file
  end
end
