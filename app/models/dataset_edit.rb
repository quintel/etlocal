class DatasetEdit < ApplicationRecord
  belongs_to :source
  belongs_to :user

  accepts_nested_attributes_for :source

  validates_presence_of :commit
  validates_presence_of :area
  validates_presence_of :key
  validates_presence_of :value
end
