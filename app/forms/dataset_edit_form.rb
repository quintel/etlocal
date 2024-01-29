class DatasetEditForm
  include ActiveModel::Model
  include Virtus.model

  EditableAttributesCollection.items.each do |item|
    attribute item.key, Float, default: item.default
  end

  # Attribute country is needed to validate the user inputs
  # in the form (see CalculableValidator)
  attribute :country, String

  validates_presence_of :number_of_inhabitants, :country
  validates :number_of_inhabitants, numericality: { greater_than: 0 }
  validates_with CalculableValidator

  def submit(dataset)
    if valid?
      previous = dataset.editable_attributes.as_json
      commit = dataset.commits.build

      attributes.except(:country).each_pair do |key, val|
        item = EditableAttributesCollection.item(key)
        next unless val.present? && previous[key.to_s] != val && item.editable?(dataset)

        commit.dataset_edits.build(key: key, value: val)
      end

      return commit
    end
    puts errors.full_messages
  end
end
