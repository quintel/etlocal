class Dataset < ApplicationRecord
  EDITABLE_ATTRIBUTES = YAML.load_file(Rails.root.join("config", "attributes.yml"))

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  def group
    if geo_id =~ /^GM/
      'municipalities'
    elsif geo_id =~ /^WK/
      'districts'
    elsif geo_id =~ /^BU/
      'neighborhoods'
    else
      'provinces'
    end
  end

  def as_json(*)
    super.except('created_at', 'updated_at')
  end

  # Public: country
  #
  # All the regions of ETLocal currently lie within the borders of Holland.
  def country
    'nl'.freeze
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
