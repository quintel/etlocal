Atlas.data_dir = '../etsource'

Etsource.collection(Atlas::Dataset::Derived.all.map do |dataset|
  Dataset.new(dataset)
end)
