FactoryBot.define do
  factory :dataset do
    user
    geo_id { 'ameland' }
    name { 'ameland' }
    country { 'nl' }
  end
end
