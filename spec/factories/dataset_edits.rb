FactoryBot.define do
  factory :dataset_edit do
    commit
    key { 'number_of_cars' }
    value { 1.0 }
  end

  factory :boolean_dataset_edit, class: 'BooleanDatasetEdit' do
    commit
    key { 'enabled' }
    boolean_value { true }
  end
end
