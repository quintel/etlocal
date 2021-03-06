# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

Dir["#{Rails.root}/db/seeds/**/*.rb"].each do |file|
  require file
end

unless quintel = Group.find_by(key: 'quintel')
  quintel = Group.create!(key: 'quintel')
end

unless User.find_by(email: 'robot@quintel.com')
  User.create!(
    email: 'robot@quintel.com',
    group: quintel,
    name: 'Robot',
    password: SecureRandom.hex
  )
end

dataset_importer = DatasetImporter.new(Rails.root.join('db', 'seeds'))

if dataset_importer.valid?
  dataset_importer.import
else
  puts dataset_importer.errors
end
