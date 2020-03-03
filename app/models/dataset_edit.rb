class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value

  before_create :cannot_be_created_at_same_second

  def self.sorted
    order('`created_at` DESC')
  end

  def user
    commit.user
  end

  def as_json(*)
    super.slice('key', 'value')
  end

  # When running migrations, sometimes two edits are made on the same key.
  # It can happen these two edits are created in the db within the same second.
  # We want these edits to stay in the order they were ment, so we add one
  # second to the creation time of the latest edit
  def cannot_be_created_at_same_second
    if DatasetEdit.where(key: key, created_at: Time.now).any?
      self.created_at = Time.now + 1
    end
  end
end
