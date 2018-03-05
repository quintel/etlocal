module Etsource
  def self.datasets
    @datasets ||= Hash[Atlas::Dataset::Derived.all.map do |dataset|
      [dataset.geo_id, dataset]
    end]
  end
end
