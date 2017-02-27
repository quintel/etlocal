class DatasetAnalyzer
  class Base
    def self.analyze(key, value)
      new(key, value).analyze
    end

    def initialize(key, value)
      @key = key
      @value = value
    end

    def analyze
      raise NotImplentedError, "base class '#{ self.class }' misses analyze method"
    end
  end
end
