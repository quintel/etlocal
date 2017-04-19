class EditableAttributesCollection
  ORDER = %w(households buildings transport).freeze

  def initialize(dataset)
    @dataset    = dataset
    @attributes = attributes.map do |key, options|
      EditableAttribute.new(dataset, key, edits[key] || [], options)
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
    sorted.group_by(&:group)
  end

  def exists?(method)
    all.map(&:key).include?(method)
  end

  def edits
    @edits ||= @dataset.edits.order("`created_at` DESC").group_by(&:key)
  end

  def as_json(*)
    all.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value
    end
  end

  private

  def sorted
    all.sort_by do |attribute|
      ORDER.index(attribute.group) || Float::INFINITY
    end
  end

  def attributes
    Dataset::EDITABLE_ATTRIBUTES.merge(assumptions)
  end

  def assumptions
    GraphAssumptions.get.values.inject(:merge) || {}
  end
end
