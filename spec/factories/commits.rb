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
          key: 'number_of_residences',
          value: 1.0,
          commit: commit
        )
      end
    end
  end
end
