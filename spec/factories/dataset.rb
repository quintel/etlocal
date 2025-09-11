FactoryBot.define do
  factory :dataset do
    user
    geo_id { 'test1' }
    name { 'ameland' }
    parent { 'nl' }
  end
end
