class AttributesDecorator
  EDITABLE_TYPES = {
    booleans: Axiom::Types::Boolean,
    floats: Axiom::Types::Float
  }.freeze

  def self.decorate(attributes)
    new(attributes).decorate
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def decorate
    EDITABLE_TYPES.map do |key, type|
      [key, @attributes.select do |attr|
        attr.type == type
      end]
    end
  end
end
