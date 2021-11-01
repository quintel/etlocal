# frozen_string_literal: true

# rubocop:disable Naming/MethodName

module DatasetSource
  module ENTSO
    # Runtime for executing queries in CSV-sourced datasets.
    class Runtime < Rubel::Runtime::Sandbox
      # Public: Creates a new Runtime instance with the given DatasetSource.
      def initialize(geo_id, energy_balance)
        super()

        @geo_id = geo_id
        @energy_balance = energy_balance
      end

      def inspect
        "#<ETLocal::Runtime (#{@geo_id})>"
      end

      def to_s
        "ETLocal::Runtime(#{@geo_id})"
      end

      # Public: Looks up the value from the enrgy balance CSV at the specified row and column.
      def EB(row, column)
        @energy_balance.get!(row.to_s, column.to_s)
      rescue ::KeyError
        ::Kernel.raise "Energy balance for #{@geo_id} does not have an entry matching " \
                       "row=#{row.inspect} and column=#{column.inspect}"
      end
    end
  end
end

# rubocop:enable Naming/MethodName
