Transformer.root = Rails.root.join('config')

# When we need to determine keys which might be defined within a dataset, rather than globally (such
# as keys within CSV files), files from canonical dataset will be used to create these keys.
Transformer.canonical_dataset_key = :nl
