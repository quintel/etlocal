# frozen_string_literal: true

class InterfaceItem
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :unit, :key
  validates_inclusion_of :unit, in: %w[# kg kg/MJ km TJ % Mton km<sup>2</sup> € MW meter flh]

  attribute :key, Symbol
  attribute :unit, String
  attribute :flexible, Boolean, default: false
  attribute :default, Float
  attribute :skip_validation, Boolean, default: false
  attribute :hidden, Boolean, default: false
  attribute :precision, Integer, default: 2

  # Queries for CSV-based datasets.
  attribute :entso, String

  # Used by file history items.
  attribute :paths, Array[String], default: []

  def self.all
    InterfaceElement.items
  end

  def group
    InterfaceGroup.all.select{ |group| group.items.select{ |item| item.key == key }.present? }.first
  end

  def combination_method
    group.combination_method || attributes[:combination_method]
  end

  def whitelisted?
    Etsource.whitelisted_attributes.include?(key) ||
      key.to_s.start_with?('input_')
  end

  def editable?(dataset)
    !dataset.queryable_source? || entso.blank?
  end
end
