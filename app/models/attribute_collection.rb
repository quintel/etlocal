module AttributeCollection
  # Module which contains the attributes as methods from an Atlas dataset
  # also includes the initializer inputs as methods. Return the original
  # values only.

  EDITABLE_ATTRIBUTES = YAML.load_file(Rails.root.join("config", "attributes.yml"))

  def editable_attributes
    @editable_attributes ||= EditableAttributesCollection.new(self)
  end

  def percentage_of_old_residences
    return unless number_of_old_residences

    (number_of_old_residences / number_of_residences) * 100
  end

  def building_area
  end

  def gas_consumption
  end

  def gas_consumption_buildings
  end

  def electricity_consumption
  end

  def electricity_consumption_buildings
  end

  def roof_surface_available_for_pv
  end

  def number_of_residences_with_solar_pv
  end

  def number_of_inhabitants
    if atlas_dataset
      atlas_dataset.number_of_inhabitants
    end
  end

  def number_of_cars
    if atlas_dataset
      atlas_dataset.number_of_cars
    end
  end

  def number_of_residences
    if atlas_dataset
      atlas_dataset.number_of_residences
    end
  end

  def number_of_old_residences
    if atlas_dataset
      atlas_dataset.number_of_old_residences
    end
  end

  def analysis_year
  end

  def static
    %i(analysis_year)
  end
end
