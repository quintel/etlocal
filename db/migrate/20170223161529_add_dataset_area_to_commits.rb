class AddDatasetAreaToCommits < ActiveRecord::Migration[5.0]
  def change
    add_column :commits, :dataset_area, :string, after: :id
  end
end
