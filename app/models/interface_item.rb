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
  attribute :precision, Integer, default: 2

  # Used by file history items.
  attribute :paths, Array[String], default: []

  def whitelisted?
    Etsource.whitelisted_attributes.include?(key) ||
      key.to_s.start_with?('input_')
  end
end
