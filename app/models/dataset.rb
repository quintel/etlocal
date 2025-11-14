class Dataset < ApplicationRecord
  str_enum :data_source, %i[db entso], scopes: false, suffix: :data_source

  belongs_to :user

  has_many :commits
  has_many :edits, through: :commits, source: :dataset_edits

  validates :geo_id,  presence: true
  validates :name,    presence: true
  validates :parent, presence: true, inclusion: {in: Etsource.available_datasets}

  ORDER = %w[
    country
    province
    res
    region
    municipality
    district
    neighborhood
  ].freeze

  def self.clones(dataset, _user)
    where(geo_id: dataset.geo_id)
      .order(Arel.sql("FIELD(`id`, #{dataset.id}) DESC, `created_at` DESC"))
  end

  # Search for query in geo_id and name, if a parent is specified, filters to that parent
  # Sorts the results by group, and puts the most relevant results first in each group
  def self.fuzzy_search(query, in_parent)
    pattern = "%#{query}%"
    results = where(arel_table[:geo_id].matches(pattern))
      .or(where(arel_table[:name].matches(pattern)))

    results = results.select { |d| d.actual_parent == in_parent } if in_parent != 'any'

    results.sort_by do |d|
      (ORDER.index(d.group) || (ORDER.length + 1)) -
        ((d.name.start_with?(query.capitalize) && 0.5) || 0)
    end
  end

  def group
    if geo_id.start_with?('GM', 'BEGM', 'DKGM')
      'municipality'
    elsif geo_id.start_with?('WK')
      'district'
    elsif geo_id.start_with?('BU', 'BEBU')
      'neighbourhood'
    elsif geo_id.start_with?('RG')
      'region'
    elsif entso_data_source? || geo_id.start_with?('UKNI') || geo_id.start_with?('GB')
      'country'
    elsif geo_id.start_with?('RES', 'ES')
      'res'
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
        base_dataset: parent,
        geo_id:
      )
  end

  def base_dataset
    return parent unless editable_attributes.exists?('analysis_year')

    base_dataset = "#{parent}#{editable_attributes.find('analysis_year').value.to_i}"
    return parent unless Etsource.available_datasets.include?(base_dataset)

    base_dataset
  end

  def editable_attributes
    @editable_attributes ||= EditableAttributesCollection.new(self)
  end

  def editable_attributes_before(date)
    EditableAttributesCollection.new(self, date)
  end

  # Public: A version of the dataset name with normalize unicode characters, and
  # any non-alphanumeric characters removed.
  #
  # Returns a string.
  def normalized_name
    I18n.transliterate(name.strip, locale: :en)
      .downcase.gsub(/[^0-9a-z_\s-]/, '').gsub(/[\s_-]+/, '_')
  end

  def temp_name
    @temp_name ||= "#{SecureRandom.hex(10)}-#{normalized_name}"
  end

  def creator
    @creator ||= if user.group
      user.group.key.humanize
    else
      user.name
    end
  end

  # This is not the parent dataset as defined in parent, but the 'real world'parent
  def actual_parent
    return geo_id.downcase if entso_data_source?
    return geo_id[..1].downcase if %w[UK BE GB].include?(geo_id[..1])

    parent[..1]
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
