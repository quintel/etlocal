# frozen_string_literal: true

class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates :key, presence: true
  validate :attribute_allowed
  validate :value_presence

  BOOLEAN_TYPE = ActiveRecord::Type::Boolean.new

  scope :before, ->(date) { joins(:commit).where("commits.created_at <= ?", date) if date.present? }
  scope :sorted, -> { order(created_at: :desc) }

  delegate :user, :dataset, to: :commit

  class << self
    def cast_from_csv(key, raw_value)
      return if raw_value.nil?

      boolean_attribute?(key) ? BOOLEAN_TYPE.cast(raw_value) : raw_value
    end

    def boolean_attribute?(key)
      InterfaceItem.find(key.to_sym)&.unit == 'boolean'
    end

    def build_for(commit, key, value)
      if boolean_attribute?(key)
        commit.dataset_edits.build(
          key: key,
          type: BooleanDatasetEdit.name,
          boolean_value: value
        )
      else
        commit.dataset_edits.build(key: key, value: value)
      end
    end

    def current_value_for(attribute)
      return unless attribute

      latest = attribute.latest
      return latest.cast_value if latest

      attribute.value
    end
  end

  def creator
    user.group ? user.group.key.humanize : user.name
  end

  def as_json(*)
    { key: key, value: cast_value }
  end

  def cast_value
    is_a?(BooleanDatasetEdit) ? boolean_value : value
  end

  private

  def value_presence
    return if boolean_type? || value.present?

    errors.add(:value, "can't be blank")
  end

  def attribute_allowed
    return if key.blank? || commit&.dataset.nil?

    val = cast_value
    return if val.blank?

    item = EditableAttributesCollection.item(key)

    unless item
      errors.add(:key, 'does not have a matching interface element')
      return
    end

    return if item.editable?(commit.dataset)

    errors.add(:value, 'is not allowed to be changed (update the energy balance CSV instead)')
  end

  def boolean_type?
    is_a?(BooleanDatasetEdit) || type == 'BooleanDatasetEdit'
  end
end
