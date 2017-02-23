class Commit < ApplicationRecord
  belongs_to :source
  belongs_to :user

  has_many :dataset_edits, inverse_of: :commit

  accepts_nested_attributes_for :dataset_edits, :source
end
