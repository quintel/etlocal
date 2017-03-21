module Etsource
  def self.datasets
    @datasets ||= Hash[Atlas::Dataset::Derived.all.map do |dataset|
      [dataset.geo_id, dataset]
    end]
  end

  def self.inputs
    @inputs ||= Atlas::InitializerInput.all.map do |input|
      Input.new(input)
    end
  end
end
