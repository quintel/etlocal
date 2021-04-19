class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value

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
end
