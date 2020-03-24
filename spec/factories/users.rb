FactoryBot.define do
  sequence :email do |n|
    "tester_#{n}@test.com"
  end

  factory :user do
    email { generate(:email) }
    name { 'Tester' }
    password { '*****' }
    group
  end
end
