module AttributeCollection
  # Module which contains the attributes as methods from an Atlas dataset
  # also includes the initializer inputs as methods. Return the original
  # values only.

  EDITABLE_ATTRIBUTES = YAML.load_file(Rails.root.join("config", "attributes.yml"))
  ATLAS_ATTRIBUTES    = %i(base_dataset
                           analysis_year
                           area
                           id
                           number_of_residences
                           number_of_inhabitants
                           number_of_cars)

  def set_attributes
    ATLAS_ATTRIBUTES.each do |attribute|
      define_singleton_method attribute do
        @atlas_dataset.public_send(attribute)
      end
    end
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

  def percentage_of_old_residences
    (@atlas_dataset.number_of_old_residences / number_of_residences) * 100
  end

  def gas_consumption
    nil
  end

  def electricity_consumption
    nil
  end

  def roof_surface_available_for_pv
  end

  def number_of_residences_with_solar_pv
  end

  def static
    %i(base_dataset analysis_year)
  end
end
