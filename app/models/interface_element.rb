# frozen_string_literal: true

class InterfaceElement < YmlReadOnlyRecord
  include Virtus.model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :key, presence: true

  attribute :key, Symbol
  attribute :groups, Array[InterfaceGroup]

  def self.groups
    @groups ||= all.flat_map(&:groups).compact
  end

  def self.items
    @items ||= all.flat_map(&:groups).flat_map(&:items).compact
  end
end
