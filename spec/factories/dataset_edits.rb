FactoryGirl.define do
  factory :dataset_edit do
    user
    source
    commit "Some commit"
    dataset_id 10
    key "number_of_cars"
    value 1.0
  end
end
