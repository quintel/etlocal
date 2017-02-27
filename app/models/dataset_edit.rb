class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value

  def self.sorted
    order('`created_at` DESC')
  end

  def as_json(*)
    super.slice('key', 'value')
  end
end
