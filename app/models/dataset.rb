class Dataset < ApplicationRecord
  belongs_to :user

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  validates :geo_id,  presence: true
  validates :name,    presence: true
  validates :country, presence: true
  validates_each :country, allow_nil: true do |record, atrr, value|
    unless Etsource.available_countries.include? value.downcase
      record.errors.add(value.downcase, 'must be in ETsource')
    end
  end

  def self.clones(dataset, user)
    where(geo_id: dataset.geo_id)
      .order(Arel.sql("FIELD(`id`, #{dataset.id}) DESC, `created_at` DESC"))
  end

  # Search for query in geo_id and name - works kind of fine, but not as fuzzy as I hoped
  def self.fuzzy_search(query)
    pattern = "%#{query}%"
    where(arel_table[:geo_id].matches(pattern)).or(where(arel_table[:name].matches(pattern)))
  end

  def group
    if geo_id =~ /^GM/ or geo_id =~ /^BEGM/
      'municipality'
    elsif geo_id =~ /^WK/
      'district'
    elsif geo_id =~ /^BU/ or geo_id =~ /^BEBU/
      'neighbourhood'
    elsif geo_id =~ /^RG/
      'region'
    elsif geo_id =~ /^RES/
      'res'
    elsif geo_id =~ /^UKNI/
      'country'
    else
      'province'
    end
  end

  def as_json(*)
    super
      .except('created_at', 'updated_at')
      .merge(group: I18n.t("datasets.area_groups.#{group}"))
  end

  def atlas_key
    :"#{geo_id}_#{normalized_name}"
  end

  def atlas_dataset
    Etsource.datasets[atlas_key] ||
      Atlas::Dataset::Derived.new(
        key: atlas_key,
        base_dataset: country,
        geo_id: geo_id
      )
  end

  def base_dataset
    return country unless editable_attributes.exists?('analysis_year')

    base_dataset = "#{country}#{editable_attributes.find('analysis_year').value.to_i}"
    return country unless Etsource.available_countries.include? base_dataset

    base_dataset
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
