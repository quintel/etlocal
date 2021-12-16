# frozen_string_literal: true

module DatasetSource
  # Reads a CSV to provide a dataset with value.
  class Map
    # Represents a CSV file where values have already been mapped to 2-dimensional keys in a Hash.
    #
    # Allows retrieving values from the source CSV using a row and column keys. For example:
    #
    #   source = CSVSource.new({ a: { x: 1, y: 2 }, b: { x: 3, y: 4} })
    #   source.get(:a, :y) # => 2
    #
    # The Source accepts optional row and column map arguments; these should be procs which allow
    # converting from a human-readable keys to those used by the source data.
    def initialize(data = {}, row_map = KeyMap.identity, col_map = KeyMap.identity)
      @data = data
      @row_map = row_map
      @col_map = col_map
    end

    def row?(key)
      @data.key?(@row_map.call(key))
    rescue KeyError
      false
    end

    def column?(key)
      @data.values.first&.key?(@col_map.call(key)) || false
    rescue KeyError
      false
    end

    def get(row_key, col_key)
      get!(row_key, col_key)
    rescue KeyError
      nil
    end

    def get!(row_key, col_key)
      @data
        .fetch(@row_map.call(row_key))
        .fetch(@col_map.call(col_key))
    end
  end
end
