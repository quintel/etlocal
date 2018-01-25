class InterfaceGroup
  include Virtus.model

  attribute :header, String
  attribute :type, Symbol, default: :static
  attribute :items, Hash
  attribute :subgroups, Array[InterfaceGroup]
end

class InterfaceElement < YmlReadOnlyRecord
  include Virtus.model
  include ActiveModel::Conversion

  attribute :key, Symbol
  attribute :groups, Array[InterfaceGroup]
end
