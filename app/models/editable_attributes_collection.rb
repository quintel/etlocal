class EditableAttributesCollection
  def self.items
    @items ||= InterfaceElement.items
  end

  def self.item(key)
    items_by_key[key.to_sym]
  end

  def self.items_by_key
    @items_by_key ||= items.index_by(&:key)
  end

  private_class_method :items_by_key

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

  def edits_for(key)
    edits[key.to_s] || []
  end

  def as_json(*)
    @attributes.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value
    end
  end

  private

  def edits
    @edits ||= @dataset.edits
      .includes(commit: :user)
      .order(created_at: :desc)
      .group_by(&:key)
  end

  def setup_attributes(dataset)
    self.class.items.flatten.map do |item|
      EditableAttribute.new(dataset, item.key.to_s, edits, item.default, entso_query: item.entso)
    end
  end
end
