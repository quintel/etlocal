class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value
  validates :value, numericality: { greater_than: 0 }

  def self.sorted
    order('`created_at` DESC')
  end

  def user
    commit.user
  end

  def as_json(*)
    super.slice('key', 'value')
  end
end
