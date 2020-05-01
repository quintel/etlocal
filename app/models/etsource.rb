module Etsource
  module_function

  def datasets
    @datasets ||= Hash[Atlas::Dataset::Derived.all.map do |dataset|
      [dataset.geo_id, dataset]
    end]
  end

  def available_countries
    @available_countries ||= Atlas::Dataset::Full.all.map{ |d| d.area }
  end

  # Returns all dataset input keys from sparse graph queries
  # Used to check if an interface element is still required.
  def dataset_inputs
    @dataset_inputs ||= Atlas::SparseGraphQuery.all.flat_map do |query|
      query.query.scan(/DATASET_INPUT\(['"]?([a-z0-9_]+)['"]?\)/).flatten
    end
  end

  def transformers
    @transformers ||= Transformer::GraphMethods.all
  end

  # Public: A set of symbols containing all the transformer keys an dataset
  # attributes whose values may be set by users.
  #
  # Returns a Set.
  def whitelisted_attributes
    @whitelisted_attributes ||= Set.new(
      transformers.keys +
        Transformer::DatasetCast.attribute_set.map(&:name)
    ).freeze
  end
end
