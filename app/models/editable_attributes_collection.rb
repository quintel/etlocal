class EditableAttributesCollection
  ORDER = %w(households buildings transport supply).freeze

  def initialize(dataset)
    @dataset    = dataset
    @attributes = setup_attributes(dataset)
  end

  def find(key)
    @attributes.detect do |attribute|
      attribute.key == key
    end
  end

  def grouped
    sorted.group_by(&:group)
  end

  def exists?(method)
    @attributes.map(&:key).include?(method)
  end

  def edits
    @edits ||= @dataset.edits
      .includes(commit: :user)
      .order("`created_at` DESC")
      .group_by(&:key)
  end

  def as_json(*)
    @attributes.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value
    end
  end

  private

  def setup_attributes(dataset)
    Dataset::EDITABLE_ATTRIBUTES.flat_map do |key, options|
      if graph_assumptions[key.to_sym]
        SliderGroup.expand(dataset, graph_assumptions, edits, key)
      else
        EditableAttribute.new(dataset, key, edits, options)
      end
    end
  end

  def sorted
    @attributes.sort_by do |attribute|
      ORDER.index(attribute.group) || Float::INFINITY
    end
  end

  def graph_assumptions
    @graph_assumptions ||= GraphAssumptions.get
  end
end
