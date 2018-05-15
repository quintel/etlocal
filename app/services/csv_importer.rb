class CSVImporter
  MANDATORY_HEADERS = %w(area geo_id)
  ALLOWED_HEADERS = InterfaceElement.items.map { |i| i.key.to_s }

  def self.import!(file)
    new(file).import
  end

  def initialize(file)
    @csv_file = CSV.read(file, headers: true)
    @headers  = @csv_file.headers

    unless valid_headers?
      raise ArgumentError, 'contains non allowed headers'
    end

    unless all_documentation_provided?
      raise ArgumentError, 'no documentation provided for some of the headers'
    end

    unless all_values_present?
      raise ArgumentError, 'some values appear to be blank'
    end
  end

  def import
    @csv_file.each(&method(:create_dataset_and_commits))
  end

  private

  def create_dataset_and_commits(row)
    info_row = row.to_h
    dataset  = Dataset.find_or_create_by(
      info_row.slice(*MANDATORY_HEADERS).merge(user: User.robot)
    )

    info_row.slice(*item_headers).each_pair do |key, value|
      commit = dataset.commits.new(
        user:    User.robot,
        message: info_row[key + '_documentation']
      )
      commit.dataset_edits << DatasetEdit.new(key: key, value: value)
      commit.save
    end
  end

  def item_headers
    (@headers - MANDATORY_HEADERS).reject do |item|
      item =~ /_documentation$/
    end
  end

  def valid_headers?
    (MANDATORY_HEADERS - @headers).empty? &&
    (item_headers - ALLOWED_HEADERS).empty?
  end

  def all_documentation_provided?
    item_headers.all? do |header|
      @headers.include?(header + '_documentation')
    end
  end

  def all_values_present?
    @csv_file.each.all? do |row|
      row.to_h.slice(*item_headers).values.all?(&:present?)
    end
  end
end
