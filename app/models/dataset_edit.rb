class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value
end
