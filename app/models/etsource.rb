module Etsource
  def self.datasets
    @datasets ||= Hash[Atlas::Dataset::Derived.all.map do |dataset|
      [dataset.geo_id, dataset]
    end]
  end

  # Returns all dataset input keys from sparse graph queries
  # Used to check if an interface element is still required.
  def self.dataset_inputs
    @dataset_inputs ||= Atlas::SparseGraphQuery.all.flat_map do |query|
      query.query.scan(/DATASET_INPUT\(['"]?([a-z0-9_]+)['"]?\)/).flatten
    end
  end
end
