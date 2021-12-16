# frozen_string_literal: true

module DatasetSource
  # Helper module for mapping human-readable keys used in dataset GQL to the keys used in the
  # source CSV.
  module KeyMap
    # Creates a Proc KeyMap where each input key is also the output key.
    #
    # For example:
    #   map = KeyMap.identity
    #   map.call('abc') => 'abc'
    #   map.call('123') => '123'
    #
    # Returns a Proc.
    def self.identity
      ->(key) { key }
    end

    # Creates a Proc where each input key maps to an output key as defined by a hash.
    #
    # For example:
    #   map = KeyMap.from_hash('abc' => 'def', '123' => '456')
    #   map.call('abc') => 'def'
    #   map.call('123') => '456'
    #   map.call('xyz') => raises KeyError
    #
    # Returns a Proc.
    def self.from_hash(hash)
      ->(key) { hash.fetch(key) }
    end

    # Creates a Proc KeyMap where each input key maps to a downcased symbol version.
    #
    # For example:
    #   map = KeyMap.symbol
    #   map.call('Abc (def)') => :abc_def
    #   map.call('123') => :'123'
    #
    # Returns a Proc.
    def self.symbol
      ->(key) { key.tr(' ', '_').tr('-()', '').downcase.to_sym }
    end
  end
end
