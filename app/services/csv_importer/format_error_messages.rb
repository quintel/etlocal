class CSVImporter
  # Formats error messages when raising an exception.
  FormatErrorMessages = lambda do |importer|
    "Error importing new data:\n\n" +
      importer.errors.map { |str| "  * #{str}" }.join("\n")
  end
end
