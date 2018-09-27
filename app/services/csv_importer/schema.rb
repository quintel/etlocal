class CSVImporter
  # Describes the headers provided in the data CSV file and decides which
  # headers are mandatory depending on whether new regions are being created.
  class Schema
    # Internal: The list of headers specified in the CSV file.
    attr_reader :provided_headers

    # Public: Creates a new Schema.
    #
    # provided_headers - An array of header names which were provided in the
    #                    data CSV file.
    # name_required    - Boolean indicating if the `name` attribute is
    #                    mandatory.
    #
    # Returns a Schema.
    def initialize(provided_headers, name_required: false)
      @provided_headers = provided_headers
      @name_required = name_required
    end

    # Public: Headers which are required to be present in the data file.
    def mandatory_headers
      @name_required ? %w[geo_id name] : %w[geo_id]
    end

    # Public: Headers which may be omitted.
    def optional_headers
      @name_required ? [] : %w[name]
    end

    # Public: Headers which a CSV may optionally include.
    def allowed_headers
      @allowed_headers ||=
        mandatory_headers + InterfaceElement.items.map(&:key).map(&:to_s)
    end

    # Public: A list of headers from the CSV file for which there are new values
    # to be added to a commit.
    def changes
      @changes ||= @provided_headers - mandatory_headers - optional_headers
    end
  end
end
