class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value
  validate :validate_attribute_allowed

  def self.sorted
    order('`created_at` DESC')
  end

  def user
    commit.user
  end

  def creator
    user.group ? user.group.key.humanize : user.name
  end

  def as_json(*)
    super.slice('key', 'value')
  end

  private

  def validate_attribute_allowed
    return if key.blank? || value.blank? || commit.nil? || commit.dataset.nil?

    item = EditableAttributesCollection.item(key)

    unless item
      errors.add(:key, 'does not have a matching interface element')
      return
    end

    # Verifies that the dataset allows this field to be edited.
    unless item.editable?(commit.dataset)
      errors.add(:value, 'is not allowed to be changed (update the energy balance CSV instead)')
    end
  end
end
