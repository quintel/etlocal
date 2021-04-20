class Commit < ApplicationRecord
  belongs_to :dataset
  belongs_to :user

  has_many :dataset_edits, inverse_of: :commit

  accepts_nested_attributes_for :dataset_edits, reject_if: :reject_edits

  validates_presence_of :message

  private

  def reject_edits(attributes)
    attributes['value'].blank?
  end
end
