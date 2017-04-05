class Dataset < ApplicationRecord
  include AttributeCollection

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  def as_json(*)
    super.except('created_at', 'updated_at')
  end

  def atlas_dataset
    Etsource.datasets[geo_id]
  end

  def dataset_edits
    DatasetEditCollection.for(area)
  end
end
