# frozen_string_literal: true

class InterfaceItem
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :unit, :key
  validates_inclusion_of :unit, in: %w(# km TJ % Mton km<sup>2</sup> € MW meter flh)

  attribute :key, Symbol
  attribute :unit, String
  attribute :flexible, Boolean, default: false
  attribute :default, Float
  attribute :skip_validation, Boolean, default: false
  attribute :hidden, Boolean, default: false

  def whitelisted?
    Etsource.whitelisted_attributes.include?(key) ||
      key.to_s.start_with?('input_')
  end
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
end
