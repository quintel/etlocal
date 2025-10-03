# frozen_string_literal: true

class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates :key, presence: true
  validate :attribute_allowed
  validate :value_presence

  BOOLEAN_TYPE = ActiveRecord::Type::Boolean.new

  scope :before, ->(date) { joins(:commit).where(commits: { created_at: ..date }) if date }
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
      edit_type = boolean_attribute?(key) ? BooleanDatasetEdit : DatasetEdit
      attributes = { key: key }

      if edit_type == BooleanDatasetEdit
        attributes.merge!(type: BooleanDatasetEdit.name, boolean_value: value)
      else
        attributes[:value] = value
      end

      commit.dataset_edits.build(attributes)
    end

    def current_value_for(attribute)
      attribute&.latest&.cast_value || attribute&.value
    end
  end

  def creator
    user.group? ? user.group.key.humanize : user.name
  end

  def as_json(*)
    { key: key, value: cast_value }
  end

  def cast_value
    boolean_type? ? boolean_value : value
  end

  private

  def value_presence
    errors.add(:value, "can't be blank") unless boolean_type? || value.present?
  end

  def attribute_allowed
    return if key.blank? || dataset.nil?

    val = cast_value
    return if val.blank?

    item = EditableAttributesCollection.item(key)

    unless item
      errors.add(:key, 'does not have a matching interface element')
      return
    end

    return if item.editable?(dataset)

    errors.add(:value, 'is not allowed to be changed (update the energy balance CSV instead)')
  end

  def boolean_type?
    is_a?(BooleanDatasetEdit)
  end
end
