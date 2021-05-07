FactoryBot.define do
  factory :dataset do
    user
    geo_id { 'test1' }
    name { 'ameland' }
    country { 'nl' }
  end
end
