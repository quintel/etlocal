FactoryBot.define do
  factory :commit do
    user
    dataset
    message { 'test' }

    factory :initial_commit, class: Commit do
      message { 'Initial commit' }

      after(:create) do |commit|
        FactoryBot.create(
          :dataset_edit,
          key: 'present_number_of_apartments_before_1945',
          value: 1.0,
          commit: commit
        )
      end
    end
  end
end
