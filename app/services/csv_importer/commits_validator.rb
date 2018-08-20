class CSVImporter
  # Verifies that the commits file contains valid information.
  class CommitsValidator
    # Public: Validates that the commits data is correct. Returns an array of
    # error messages; array will be empty if validation succeeded.
    def self.call(importer)
      new(importer).errors
    end

    # Returns an array of errors related to commits. Returns an empty array if
    # the commit data is valid.
    def errors
      errors = []

      errors.push(*validate_messages)
      errors.push(*validate_fields)
      errors.push(*validate_csv_headers)
      errors.push(*validate_duplicates)

      errors.compact
    end

    private

    def initialize(importer)
      @importer = importer
    end

    # Internal: Asserts that all commits have a message.
    def validate_messages
      unless @importer.commits.all? { |c| c.message.present? }
        return ['one or more commits are missing a message']
      end

      []
    end

    # Internal: Asserts that each commit specifies fields which are in the
    # allowed headers list.
    def validate_fields
      @importer.commits.map do |commit|
        SubsetFieldValidator.call(
          @importer.allowed_headers, commit.keys
        )
      end.compact
    end

    # Internal: Asserts that the the fields specified in each commit exist in
    # the data CSV file.
    def validate_csv_headers
      provided = @importer.provided_headers

      @importer.commits.map do |commit|
        SubsetFieldValidator.call(
          provided, commit.keys,
          message: "contains fields which aren't present in the data"
        )
      end.compact
    end

    # Internal: Asserts that no attribute is specified more than once.
    def validate_duplicates
      return [] if @importer.commits.length < 2

      seen = Set.new(@importer.commits.first.keys)
      dups = Set.new

      @importer.commits[1..-1].each do |commit|
        if (matched = seen & commit.keys).any?
          dups.merge(matched)
        end

        seen.merge(commit.keys)
      end

      return [] if dups.empty?

      ["attributes specified in multiple commits: #{dups.to_a.join(', ')}"]
    end
  end
end
