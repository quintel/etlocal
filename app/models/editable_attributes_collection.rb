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

  def initialize(dataset, freeze_date = nil)
    @dataset    = dataset
    @freeze_date = freeze_date
    @attributes = setup_attributes
  end

  def find(key)
    @attributes.detect { |attribute| attribute.key == key }
  end

  def exists?(method)
    @attributes.any? { |attribute| attribute.key == method }
  end

  def edits_for(key)
    edits[key.to_s] || []
  end

  def as_json(*)
    @attributes.each_with_object({}) do |edit, object|
      object[edit.key] = edit.value(@freeze_date)
    end
  end

  private

  def edits
    @edits ||= @dataset.edits
      .includes(commit: :user)
      .order(created_at: :desc)
      .group_by(&:key)
  end

  def setup_attributes
    self.class.items.flatten.map do |item|
      EditableAttribute.new(
        @dataset,
        item.key.to_s,
        edits_for(item.key.to_s),
        item.default,
        entso_query: item.entso,
        freeze_date: @freeze_date
      )
    end
  end
end
