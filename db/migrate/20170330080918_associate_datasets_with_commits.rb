class AssociateDatasetsWithCommits < ActiveRecord::Migration[5.0]
  def change
    add_reference :commits, :dataset, index: true

    Commit.all.each do |commit|
      dataset = Dataset.find_by(geo_id: commit.dataset_area)
      commit.dataset_id = dataset.id
      commit.save
    end

    remove_column :commits, :dataset_area
  end
end
