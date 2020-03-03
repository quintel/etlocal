class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value

  validate :cannot_be_created_at_same_second

  def self.sorted
    order('`created_at` DESC')
  end

  def user
    commit.user
  end

  def as_json(*)
    super.slice('key', 'value')
  end

  def cannot_be_created_at_same_second
    if DatasetEdit.where(key: key, created_at: Time.now).any?
      self.created_at = Time.now + 1
    end

    true
  end
end
