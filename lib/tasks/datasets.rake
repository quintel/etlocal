namespace :dataset do
  desc "Creates dataset edits for a dataset"
  task :import => :environment do
    DatasetImporter.new.import
  end
end
