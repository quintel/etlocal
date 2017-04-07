namespace :etsource do
  desc "Exports changes of a dataset to ETSource"
  task :export => :environment do
    dataset = Atlas::Dataset::Derived.find(ENV['DATASET'])

    raise ArgumentError, "DATASET= argument is missing" unless ENV['DATASET']
    raise ArgumentError, "dataset '#{ ENV['DATASET'] }' does not exist" unless dataset

    Exporter.export(dataset)

    puts "Successfully analyzed and exported #{ dataset.area }"
  end
end
