class Dataset < ApplicationRecord
  str_enum :data_source, %i[db entso], scopes: false, suffix: :data_source

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

  ORDER = %w[
    country
    province
    res
    region
    municipality
    district
    neighborhood
  ].freeze

  def self.clones(dataset, user)
    where(geo_id: dataset.geo_id)
      .order(Arel.sql("FIELD(`id`, #{dataset.id}) DESC, `created_at` DESC"))
  end

  # Search for query in geo_id and name, if a country is specified, filters to that country
  # Sorts the results by group, and puts the most relevant results first in each group
  def self.fuzzy_search(query, in_country)
    pattern = "%#{query}%"
    results = where(arel_table[:geo_id].matches(pattern))
      .or(where(arel_table[:name].matches(pattern)))

    results = results.select { |d| d.actual_country == in_country } if in_country != 'any'

    results.sort_by do |d|
      (ORDER.index(d.group) || ORDER.length + 1) -
        ((d.name.start_with?(query.capitalize) && 0.5) || 0)
    end
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
    elsif entso_data_source? || geo_id.match?(/^UKNI/)
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

  # This is not the parent dataset as defined in country, but the 'real world'country
  def actual_country
    return geo_id.downcase if entso_data_source?
    return geo_id[..1].downcase if %w[UK BE].include?(geo_id[..1])

    country[..1]
  end

  # Public: Returns if this dataset retrieves some values from a CSV using queries.
  def queryable_source?
    # This can be extended in the future if we need to support other types of source.
    entso_data_source?
  end

  # Public: Executes the GQL query.
  def execute_query(query)
    data_source_file.runtime.execute(query)
  end

  private

  # Internal: Retrieves the data source for the dataset if it has data sourced from a CSV file.
  #
  # Returns an ETLocal::DatasetSource::ENTSOFile or raises an error if the dataset does not use a
  # CSV.
  def data_source_file
    unless entso_data_source?
      raise "Datasets whose data source is #{data_source.inspect} do not have a CSV source file"
    end

    @data_source_file ||= DatasetSource::ENTSO::File.from_dataset(self)
  end

  def is_province?
    !(geo_id =~ /^(BU|GM|WK)/)
  end
end
