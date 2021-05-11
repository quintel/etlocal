# frozen_string_literal: true

class InterfaceGroup
  include Virtus.model
  include ActiveModel::Validations

  validates :items, absence: { if: ->(model) { model.type == :files } }

  validates :paths, absence: true, unless: ->(model) { model.type == :files }

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Array[InterfaceItem]
  attribute :subgroups, Array[InterfaceGroup]

  # Used by file history pages.
  attribute :paths, Array[String]
end
