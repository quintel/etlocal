module AttributeCollection
  # Module which contains the attributes as methods from an Atlas dataset
  # also includes the initializer inputs as methods. Return the original
  # values only.

  EDITABLE_ATTRIBUTES = YAML.load_file(Rails.root.join("config", "attributes.yml"))
  ATLAS_ATTRIBUTES    = %i(base_dataset analysis_year area id)

  def set_attributes
    set_area_attributes
    set_editable_attributes
  end

  def attribute_exists?(method)
    editable_attributes.map(&:key).include?(method)
  end

  def editable_attributes
    @editable_attributes ||= begin
      EDITABLE_ATTRIBUTES.map do |name, options|
        EditableAttribute.new(self, name, options)
      end
    end
  end

  def static
    %i(base_dataset analysis_year)
  end

  private

  def set_area_attributes
    ATLAS_ATTRIBUTES.each do |attribute|
      define_singleton_method attribute do
        @atlas_dataset.public_send(attribute)
      end
    end
  end

  # Private: defines methods for editable attributes.
  #
  # Defaults for methods like 'number_of_cars' are directly readable from
  # the .ad file in question. Other methods are not useable and return nil for
  # now.
  def set_editable_attributes
    editable_attributes.each do |attribute|
      define_singleton_method attribute.key do
        begin
          @atlas_dataset.public_send(attribute.key)
        rescue NoMethodError
          nil
        end
      end
    end
  end
end
