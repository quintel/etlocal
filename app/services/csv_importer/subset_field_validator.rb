class CSVImporter
  # Verifies that an array of fields is a subset of a permitted set of fields.
  SubsetFieldValidator =
    lambda do |permitted, provided, message: 'contains unknown fields'|
      surplus = provided - permitted
      "#{message}: #{surplus.map(&:inspect).join(', ')}" if surplus.any?
    end
end
