FactoryGirl.define do
  factory :commit do
    user
    source
    dataset
    message "test"

    factory :initial_commit, class: Commit do
      message "Initial commit"

      after(:create) do |commit|
        Dataset::EDITABLE_ATTRIBUTES.each_pair do |key, opts|
          if opts['mandatory']
            FactoryGirl.create(:dataset_edit, key: key, value: 1.0, commit: commit)
          end
        end
      end
    end
  end
end
