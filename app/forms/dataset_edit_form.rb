class DatasetEditForm
  include ActiveModel::Model
  include Virtus.model

  EditableAttributesCollection.items.each do |item|
    attribute item.key, Float, default: item.default
  end

  validates_presence_of :number_of_residences
  validates :number_of_residences, numericality: { greater_than: 0 }
  validates_with CalculableValidator

  def submit(dataset)
    if valid?
      previous = dataset.editable_attributes.as_json
      commit = dataset.commits.build
      commit.build_source

      attributes.each_pair do |key, val|
        if val.present? && previous[key.to_s] != val
          commit.dataset_edits.build(
            key: key,
            value: val
          )
        end
      end

      commit
    end
  end
end
