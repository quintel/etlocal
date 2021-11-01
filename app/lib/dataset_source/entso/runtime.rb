# frozen_string_literal: true

# rubocop:disable Naming/MethodName

module DatasetSource
  module ENTSO
    # Runtime for executing queries in CSV-sourced datasets.
    class Runtime < Rubel::Runtime::Sandbox
      # Public: Creates a new Runtime instance with the given DatasetSource.
      def initialize(geo_id, source)
        super()

        @geo_id = geo_id
        @source = source
      end

      def inspect
        "#<ETLocal::Runtime (#{@geo_id})>"
      end

      def to_s
        "ETLocal::Runtime(#{@geo_id})"
      end

      # Public: Looks up the value from the enrgy balance CSV at the specified row and column.
      def EB(row, column)
        @source.get(row, column)
      end
    end
  end
end

# rubocop:enable Naming/MethodName
