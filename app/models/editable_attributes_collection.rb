class EditableAttributesCollection
  def self.keys
    @keys ||= InterfaceElement.keys
  end

  def initialize(dataset)
    @dataset    = dataset
    @attributes = setup_attributes(dataset)
  end

  def find(key)
    @attributes.detect do |attribute|
      attribute.key == key
    end
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
      next unless edit.value

      object[edit.key] = edit.value
    end
  end

  private

  def setup_attributes(dataset)
    self.class.keys.flatten.map do |key|
      EditableAttribute.new(dataset, key.to_s, edits)
    end
  end
end
