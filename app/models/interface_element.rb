class InterfaceItem
  include Virtus.model
  include ActiveModel::Validations

  validates_presence_of :unit, :key
  validates_inclusion_of :unit, in: %w(# km TJ % Mton <span>km<sup>2</sup></span>)
  validate :used_in_sparse_graph_query

  attribute :key, Symbol
  attribute :unit, String
  attribute :flexible, Boolean, default: false

  private

  def used_in_sparse_graph_query
    return unless key =~ /^input_/
    return if Etsource.dataset_inputs.include?(key.to_s)

    errors.add(:key, "#{ key } is not used within a sparse graph query 'DATASET_INPUT'")
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

  def self.keys
    InterfaceElement.all.flat_map(&:groups).flat_map do |group|
      group.items.map(&:key)
    end
  end
end
