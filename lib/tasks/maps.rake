namespace :maps do
  desc "Exports changes of a dataset to ETSource"
  task :create => :environment do
    MapTransformer.new.transform
  end
end
