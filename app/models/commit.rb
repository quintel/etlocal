class Commit < ApplicationRecord
  belongs_to :source, optional: true
  belongs_to :user

  has_many :dataset_edits, inverse_of: :commit

  accepts_nested_attributes_for :dataset_edits
  accepts_nested_attributes_for :source,
    reject_if: proc { |s| s["source_file"].blank? }

  validates_presence_of :message
end
