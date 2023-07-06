# frozen_string_literal: true

class InterfaceGroup
  include Virtus.model
  include ActiveModel::Validations

  validates :items, absence: { if: ->(model) { model.files? } }

  validates :paths, absence: true, unless: ->(model) { model.files? }

  validate :validate_paths, if: ->(model) { model.files? }

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Array[InterfaceItem]
  attribute :subgroups, Array[InterfaceGroup]
  attribute :combination_method

  # Used by file history pages.
  attribute :paths, Array[String]

  def self.all
    InterfaceElement.groups
  end

  def files?
    type == :files
  end

  private

  def validate_paths
    Array(paths).each do |path|
      if path.to_s.include?('..')
        errors.add(:paths, "may not include path to a parent directory (#{path.inspect})")
      end
    end
  end
end
