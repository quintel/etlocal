namespace :etsource do
  desc "Exports changes of a dataset to ETSource"
  task :export => :environment do
    dataset = Dataset.find(ENV['DATASET'])

    raise ArgumentError, "DATASET= argument is missing" unless ENV['DATASET']
    raise ArgumentError, "dataset '#{ ENV['DATASET'] }' does not exist" unless dataset

    Exporter.export(dataset)

    puts "Successfully analyzed and exported #{ dataset.area }"
  end

  desc "Create a new dataset"
  task :new => :environment do
    dataset = Dataset.find(ENV['DATASET'])

    raise ArgumentError, "DATASET= argument is missing" unless ENV['DATASET']
    raise ArgumentError, "dataset '#{ ENV['DATASET'] }' already exists" if dataset

    DatasetCreator.create(ENV['DATASET'])
  end
end
