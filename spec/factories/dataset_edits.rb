FactoryGirl.define do
  factory :dataset_edit do
    user
    source
    commit "Some commit"
    area "ameland"
    key "number_of_cars"
    value 1.0
  end
end
