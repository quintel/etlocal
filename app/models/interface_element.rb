class InterfaceItem
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :unit, :key
  validates_inclusion_of :unit, in: %w(# km TJ % Mton <span>km<sup>2</sup></span>)

  attribute :key, Symbol
  attribute :unit, String
  attribute :flexible, Boolean, default: false
end

class InterfaceGroup
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :items

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Array[InterfaceItem]
  attribute :subgroups, Array[InterfaceGroup]
end

class InterfaceElement < YmlReadOnlyRecord
  include Virtus.model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates_presence_of :key

  attribute :key, Symbol
  attribute :groups, Array[InterfaceGroup]

  def self.items
    @items ||= all.flat_map(&:groups).flat_map(&:items)
  end

  def self.keys
    InterfaceElement.all.flat_map(&:groups).flat_map do |group|
      group.items.map(&:key)
    end
  end
end
