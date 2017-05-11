class Dataset < ApplicationRecord
  EDITABLE_ATTRIBUTES  = YAML.load_file(Rails.root.join("config", "attributes.yml"))
  EDITABLE_ASSUMPTIONS = YAML.load_file(Rails.root.join("config", "editable_assumptions.yml"))

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  def self.provinces
    where("`geo_id` NOT LIKE 'BU%' AND `geo_id` NOT LIKE 'WK%' AND `geo_id` NOT LIKE 'GM%'")
  end

  def self.neighborhoods
    where("`geo_id` LIKE 'BU%'")
  end

  def self.districts
    where("`geo_id` LIKE 'WK%'")
  end

  def self.municipalities
    where("`geo_id` LIKE 'GM%'")
  end

  def as_json(*)
    super.except('created_at', 'updated_at')
  end

  def atlas_dataset
    Etsource.datasets[geo_id]
  end

  def chart_id
    if is_province?
      geo_id.titleize.sub(/\s/, '-')
    else
      geo_id
    end
  end

  def editable_attributes
    @editable_attributes ||= EditableAttributesCollection.new(self)
  end

  private

  def is_province?
    !(geo_id =~ /^(BU|GM|WK)/)
  end
end
