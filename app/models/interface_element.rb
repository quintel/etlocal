class InterfaceGroup
  include Virtus.model

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Hash[Symbol => String]
  attribute :subgroups, Array[InterfaceGroup]
end

class InterfaceElement < YmlReadOnlyRecord
  include Virtus.model
  include ActiveModel::Conversion

  attribute :key, Symbol
  attribute :groups, Array[InterfaceGroup]

  def self.keys
    InterfaceElement.all.flat_map(&:groups).flat_map do |group|
      group.items.keys
    end
  end
end
