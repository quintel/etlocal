FactoryGirl.define do
  sequence :email do |n|
    "tester_#{ n }@test.com"
  end

  factory :user do
    email { generate(:email) }
    name "Tester"
    password "******"
    group

    factory :quintel_user do
      group { Group.find_by_key(:quintel) }
    end
  end
end
