# frozen_string_literal: true

# Takes a path to a CSV data file and a YAML commits file and creates new
# commits and dataset edits.
class CSVImporter
  # Commits which specify a single :all field will use all the provided fields
  # from the data.
  GLOB_COMMIT_FIELDS = [:all].freeze

  attr_reader :data_path, :commits_path, :errors

  # Public: Creates a CSV importer reading the given data and commit paths.
  #
  # An optional block allows the import of each row to be manually triggered so
  # as to run before and after callbacks. See CSVImporter#run.
  #
  # Returns an array of the commits which were created.
  def self.run(data_path, commits_path, &block)
    new(data_path, commits_path).run(&block)
  end

  def initialize(data_path, commits_path)
    @data_path     = data_path.to_s
    @commits_path  = commits_path.to_s
    @has_validated = false
    @errors        = []
  end

  # Public: Reads the CSV and commits file, creating a new commits for each
  # dataset as appropriate.
  #
  # If `run` is provided a block, it will yield the CSV row and a callable which
  # will trigger importing the row data. For example:
  #
  #   csv_importer.run do |row, runner|
  #     print "Importing #{row['geo_id']... "
  #     runner.call
  #     puts 'done!'
  #   end
  #
  # Returns an array of all commits which were created.
  def run
    raise FormatErrorMessages.call(self) unless valid?

    ActiveRecord::Base.transaction do
      data_file.flat_map do |row|
        if block_given?
          row_commits = nil
          yield(row, -> { row_commits = run_row(row) })
          row_commits
        else
          run_row(row)
        end
      end
    end
  end

  def valid?
    validate unless @has_validated
    @errors.empty?
  end

  # Internal: An array of importable commits.
  #
  # Returns an array.
  def commits
    @commits ||= YAML.load_file(@commits_path).map do |commit_data|
      fields =
        if commit_data['fields'] == GLOB_COMMIT_FIELDS
          provided_headers - mandatory_headers
        else
          commit_data['fields']
        end

      ImportableCommit.new(fields, commit_data['message'])
    end
  end

  # Internal: Headers which every data CSV must include.
  def mandatory_headers
    %w[geo_id]
  end

  # Internal: Headers which a CSV may optionally include.
  def allowed_headers
    @allowed_headers ||=
      mandatory_headers + InterfaceElement.items.map(&:key).map(&:to_s)
  end

  # Internal: The list of headers specified in the CSV file.
  def provided_headers
    @provided_headers ||= data_file.peek.headers
  end

  private

  # Internal: Asserts that the commit and data are valid and consistent,
  # otherwise raises an error.
  def validate
    @has_validated = true

    unless File.exist?(@commits_path)
      @errors.push("#{File.basename(@commits_path)}: does not exist")
    end

    unless File.exist?(@data_path)
      @errors.push("#{File.basename(@data_path)}: does not exist")
    end

    # Stop as further validations need to read the files.
    return if @errors.any?

    begin
      data_file.peek
    rescue StopIteration
      @errors.push("#{File.basename(@data_path)}: has no data to import")
      return
    end

    DataValidator.call(self).each do |error|
      @errors.push("#{File.basename(@data_path)}: #{error}")
    end

    CommitsValidator.call(self).each do |error|
      @errors.push("#{File.basename(@commits_path)}: #{error}")
    end

    nil
  end

  # Internal: Enumerable containing each parsed CSV::Row in the data file.
  #
  # Returns an enumerable.
  def data_file
    @data_file ||= CSV.foreach(@data_path, headers: true, converters: :numeric)
  end

  # Internal: Finds the dataset which represents a CSV row.
  def dataset_from_row(row)
    criteria = Hash[mandatory_headers.map { |key| [key, row[key]] }]
    Dataset.where(criteria.merge(user: User.robot)).first!
  rescue ActiveRecord::RecordNotFound => ex
    raise ActiveRecord::RecordNotFound,
      "No dataset exists matching: #{criteria.inspect}",
      ex.backtrace
  end

  # Internal: Runs the CSV importer for a single row in the data file.
  def run_row(row)
    dataset = dataset_from_row(row)

    commits.map do |c|
      commit = c.build_commit(dataset, row)

      next if commit.dataset_edits.none?

      commit.save!
      commit
    end
  end
end
