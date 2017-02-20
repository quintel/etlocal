module Etsource
  def self.datasets
    @datasets ||= Atlas::Dataset::Derived.all.map do |dataset|
      Dataset.new(dataset)
    end
  end

  def self.inputs
    @inputs ||= Atlas::InitializerInput.all.map do |input|
      Input.new(input)
    end
  end
end
