class CSVImporter
  # Verifies that the data file contains valid information.
  class DataValidator
    # Public: Validates that the data is correct. Returns an array of error
    # messages; array will be empty if validation succeeded.
    def self.call(importer)
      new(importer).errors
    end

    # Returns an array of errors related to the data file. Returns an empty
    # array if the data is valid.
    def errors
      # Assert that each header in the CSV is used by a commit.
      [
        SubsetFieldValidator.call(
          @importer.commits.flat_map(&:keys).uniq,
          @importer.provided_headers -
            @importer.mandatory_headers -
            @importer.optional_headers,
          message: 'contains fields not used by any commit'
        ),
        SubsetFieldValidator.call(
          @importer.provided_headers,
          @importer.mandatory_headers,
          message: 'is missing mandatory headers'
        )
      ].compact
    end

    private

    def initialize(importer)
      @importer = importer
    end
  end
end
