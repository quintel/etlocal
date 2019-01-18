class Dataset < ApplicationRecord
  belongs_to :user

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  validates :geo_id, presence: true
  validates :name,   presence: true

  def self.clones(dataset, user)
    where(geo_id: dataset.geo_id)
      .order("FIELD(`id`, #{dataset.id}) DESC, `created_at` DESC")
  end

  def group
    if geo_id =~ /^GM/ or geo_id =~ /^BEGM/
      'municipality'
    elsif geo_id =~ /^WK/
      'district'
    elsif geo_id =~ /^BU/
      'neighbourhood'
    elsif geo_id =~ /^RG/
      'region'
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

  # Public: A version of the dataset name with normalize unicode characters, and
  # any non-alphanumeric characters removed.
  #
  # Returns a string.
  def normalized_name
    name.strip.mb_chars.normalize(:kd).to_s
      .downcase.gsub(/[^0-9a-z_\s\-]/, '').gsub(/[\s_-]+/, '_')
  end

  def temp_name
    @temp_name ||= "#{SecureRandom.hex(10)}-#{normalized_name}"
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
