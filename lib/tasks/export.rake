namespace :etsource do
  desc "Exports changes of a dataset to ETSource"
  task :export => :environment do
    dataset = Dataset.find(ENV['DATASET'])

    raise ArgumentError, "DATASET= argument is missing" unless ENV['DATASET']
    raise ArgumentError, "dataset '#{ ENV['DATASET'] }' does not exist" unless dataset

    Exporter.export(dataset)
  end
end
