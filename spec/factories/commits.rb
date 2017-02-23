FactoryGirl.define do
  factory :commit do
    user
    source
    dataset_area 'ameland'
    message "test"
  end
end
