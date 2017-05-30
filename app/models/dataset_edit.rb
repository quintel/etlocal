class DatasetEdit < ApplicationRecord
  belongs_to :commit

  validates_presence_of :key
  validates_presence_of :value, if: proc { !boolean? }
  validates :value, numericality: { greater_than_or_equal_to: 0 },
                    if: proc { |f|
                      !boolean? && f.key != 'number_of_households'
                    }

  validates :value, numericality: { greater_than: 0 },
                    if: proc { |f|
                      !boolean? && f.key == 'number_of_households'
                    }

  def self.sorted
    order('`created_at` DESC')
  end

  def user
    commit.user
  end

  def unit
    options['unit']
  end

  def as_json(*)
    super.slice('key', 'value')
  end

  def parsed_value
    boolean? ? ActiveRecord::Type::Boolean.new.deserialize(value.to_i) : value
  end

  private

  def boolean?
    options['unit'] == 'bool'
  end

  def options
    Dataset::EDITABLE_ATTRIBUTES[key] || {}
  end
end
