module Etsource
  def self.collection
    @datasets ||= Atlas::Dataset::Derived.all.map do |dataset|
      Dataset.new(dataset)
    end
  end
end
