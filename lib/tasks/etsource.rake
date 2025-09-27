# frozen_string_literal: true

namespace :etsource do
  desc <<-DESC
    Exports changes of a dataset to ETSource

    Requires a DATASET argument. It exports data from a remote source which
    you can set in the .env file with the EXPORT_ROOT variable.

    for localhost use:
    - localhost:3000

    for production use:
    - data.energytransitionmodel.com

    Optional argument TIME_CURVES_TO_ZERO, default true, does not scale
    timecurves when set to true.

    Optional argument REBUILD, default true, removes the dataset folder from
    ETSource before generating a new set when true. This means a new dataset id
    in ETSource is generated, the old one will be removed

  DESC

  task export: :environment do
    raise ArgumentError, 'DATASET= argument is missing' unless ENV['DATASET']

    rebuild = ENV['REBUILD'].nil? or ENV['REBUILD'] == 'true'
    Exporter.export(ENV['DATASET'], rebuild: rebuild)
  end
end
