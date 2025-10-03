class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates :key, presence: true
  validate :attribute_allowed
  validate :value_presence

  scope :before, ->(date) { joins(:commit).where(commits: { created_at: ..date }) if date }
  scope :sorted, -> { order(created_at: :desc) }

  delegate :user, to: :commit

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
    return if is_a?(BooleanDatasetEdit) || value.present?

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
end
