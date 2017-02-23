module AttributeCollection
  EDITABLE_TYPES = { booleans: Axiom::Types::Boolean, floats: Axiom::Types::Float }.freeze

  ATLAS_ATTRIBUTES = %i(base_dataset analysis_year area id)

  ATLAS_ATTRIBUTES.each do |attribute|
    define_method attribute do
      @atlas_dataset.public_send(attribute)
    end
  end

  def static
    %i(base_dataset analysis_year)
  end

  def editable
    EDITABLE_TYPES.map do |key, type|
      [key, attribute_set.select { |attr| attr.type == type }]
    end
  end

  def inputs
    Input.sorted
  end

  def attribute_exists?(key)
    (attribute_set.map(&:name) + Input.all.map(&:key)).include?(key.to_sym)
  end

  private

  def attribute_set
    @atlas_dataset.send(:attribute_set)
  end
end
