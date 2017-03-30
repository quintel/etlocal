FactoryGirl.define do
  factory :commit do
    user
    source
    dataset
    message "test"
  end
end
