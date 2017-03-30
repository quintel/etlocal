class EditableAttributesCollection
  def initialize(dataset)
    @attributes = Dataset::EDITABLE_ATTRIBUTES.map do |name, options|
      EditableAttribute.new(dataset, name, options)
    end
  end

  def all
    @attributes
  end

  def find(key)
    all.detect do |attribute|
      attribute.key == key
    end
  end

  def grouped
    all.group_by(&:group)
  end

  def exists?(method)
    all.map(&:key).include?(method)
  end
end
