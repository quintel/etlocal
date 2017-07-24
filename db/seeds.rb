# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

Dir["#{ Rails.root }/db/seeds/**/*.rb"].each do |file|
  require file
end

DatasetImporter.new.import

unless User.find_by(email: "robot@quintel.com")
  User.create!(email: "robot@quintel.com", name: "Robot", password: SecureRandom.hex)
end
