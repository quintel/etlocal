FactoryBot.define do
  factory :source do
    source_file { File.new(Rails.root.join('spec', 'fixtures', 'test.xls')) }
  end
end
