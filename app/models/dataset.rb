class Dataset < ApplicationRecord
  include AttributeCollection

  def atlas_dataset
    Etsource.datasets[geo_id]
  end

  def dataset_edits
    DatasetEditCollection.for(area)
  end
end
