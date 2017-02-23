module AttributeCollection
  # Module which contains the attributes as methods from an Atlas dataset
  # also includes the initializer inputs as methods. Return the original
  # values only.

  EDITABLE_TYPES   = [Axiom::Types::Boolean, Axiom::Types::Float].freeze
  ATLAS_ATTRIBUTES = %i(base_dataset analysis_year area id)

  def methodize?(attribute)
    EDITABLE_TYPES.any?{|a| a.include?(attribute.type) } ||
    ATLAS_ATTRIBUTES.include?(attribute.name)
  end

  def set_attributes
    set_area_attributes
    set_input_attributes
  end

  def set_area_attributes
    editable.each do |attribute|
      if methodize?(attribute)
        define_singleton_method attribute.name do
          @atlas_dataset.public_send(attribute.name)
        end
      end
    end
  end

  def set_input_attributes
    inputs.each do |input|
      define_singleton_method input.key do
        @atlas_dataset.init[input.key]
      end
    end
  end

  def static
    %i(base_dataset analysis_year)
  end

  def editable
    @atlas_dataset.send(:attribute_set)
  end

  def inputs
    Input.all
  end

  alias_method :attribute_exists?, :respond_to?
end
