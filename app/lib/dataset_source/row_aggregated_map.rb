# frozen_string_literal: true

module DatasetSource
  # Takes an existing map and a hash of aliases for rows, and provides an API compatiable with Map
  # such that requesting a row by its alias will return the sum of all matching values from the
  # original.
  #
  # For example:
  #   map = Map.new(a: { x: 1 }, b: { x: 2 })
  #   agg = RowAggregatedMap.new(map, alias: [:a, :b])
  #   agg.get(:alias, :x) # => 3
  #
  class RowAggregatedMap
    def initialize(map, aliases)
      @map = map
      @aliases = aliases
    end

    def row?(key)
      @map.row?(key) || @aliases.key?(key)
    end

    def column?(key)
      @map.column?(key)
    end

    # Public: Gets a value by the row and column key.
    #
    # If the row key matches one of the aliases in the RowAggregatedMap, all matching rows in the
    # original map will be summed, with the summed value returned. Otherwise it is assumed that the
    # row key matches a row in the original.
    #
    # Returns a numeric or nil.
    def get(row_key, col_key)
      get!(row_key, col_key)
    rescue KeyError
      nil
    end

    # Public: Gets a value by the row and column key.
    #
    # If the row key matches one of the aliases in the RowAggregatedMap, all matching rows in the
    # original map will be summed, with the summed value returned. Otherwise it is assumed that the
    # row key matches a row in the original.
    #
    # Returns a numeric or raises a KeyError when no matching row exists.
    def get!(row_key, col_key)
      if @aliases.key?(row_key)
        @aliases[row_key].sum { |aliased_key| @map.get!(aliased_key, col_key) }
      else
        @map.get!(row_key, col_key)
      end
    end
  end
end
