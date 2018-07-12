class Dataset < ApplicationRecord
  belongs_to :user

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  def self.clones(dataset, user)
    where(geo_id: dataset.geo_id)
      .order(Arel.sql(sanitize_sql_array([
        "FIELD(`id`, ?) DESC, `created_at` DESC",
        dataset.id
      ])))
  end

  def group
    if geo_id =~ /^GM/
      'municipality'
    elsif geo_id =~ /^WK/
      'neighbourhood'
    elsif geo_id =~ /^BU/
      'neighbourhood'
    else
      'province'
    end
  end

  def as_json(*)
    super
      .except('created_at', 'updated_at')
      .merge(group: I18n.t("datasets.area_groups.#{group}"))
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

  def temp_name
    @temp_name ||= begin
      stripped = area.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

      "#{ SecureRandom.hex(10) }-#{ stripped }"
    end
  end

  def creator
    @creator ||= begin
      if user.group
        user.group.key.humanize
      else
        user.name
      end
    end
  end

  private

  def is_province?
    !(geo_id =~ /^(BU|GM|WK)/)
  end
end
