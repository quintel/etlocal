# frozen_string_literal: true

class Commit < ApplicationRecord
  belongs_to :dataset
  belongs_to :user

  has_many :dataset_edits, inverse_of: :commit

  accepts_nested_attributes_for :dataset_edits, reject_if: :reject_edits

  validates :message, presence: true

  def add_dataset_edit(key, value)
    cast_value = DatasetEdit.cast_from_csv(key, value)
    return nil if cast_value.nil?

    if DatasetEdit.boolean_attribute?(key)
      dataset_edits.build(
        key: key,
        type: BooleanDatasetEdit.name,
        boolean_value: cast_value
      )
    else
      dataset_edits.build(
        key: key,
        value: cast_value
      )
    end
  end

  private

  def reject_edits(attributes)
    attributes['value'].blank?
  end
end
