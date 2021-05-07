# frozen_string_literal: true

class InterfaceItem
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :unit, :key
  validates_inclusion_of :unit, in: %w[# kg km TJ % Mton km<sup>2</sup> € MW meter flh]

  attribute :key, Symbol
  attribute :unit, String
  attribute :flexible, Boolean, default: false
  attribute :default, Float
  attribute :skip_validation, Boolean, default: false
  attribute :hidden, Boolean, default: false

  # Used by file history items.
  attribute :paths, Array[String], default: []

  def whitelisted?
    Etsource.whitelisted_attributes.include?(key) ||
      key.to_s.start_with?('input_')
  end
end

class InterfaceGroup
  include Virtus.model
  include ActiveModel::Validations

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Array[InterfaceItem]
  attribute :subgroups, Array[InterfaceGroup]
end

class InterfaceElement < YmlReadOnlyRecord
  include Virtus.model
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :key, presence: true
  validates :paths, absence: true, unless: ->(model) { model.type == 'files' }

  attribute :key, Symbol
  attribute :groups, Array[InterfaceGroup]
  attribute :type, String, default: 'inputs'

  # Used by file history pages.
  attribute :paths, Array[String]

  def self.items
    @items ||= all.flat_map(&:groups).flat_map(&:items)
  end
end
