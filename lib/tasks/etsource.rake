namespace :etsource do
  desc <<-eos
    Exports changes of a dataset to ETSource

    Requires a DATASET argument. It exports data from a remote source which
    you can set in the .env file with the EXPORT_ROOT variable.

    for localhost use:
    - localhost:3000

    for beta use:
    - beta-local.energytransitionmodel.com

  eos
  task :export => :environment do
    raise ArgumentError, "DATASET= argument is missing" unless ENV['DATASET']

    Exporter.export(ENV['DATASET'])
  end
end
