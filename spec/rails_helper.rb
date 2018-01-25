ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require "paperclip/matchers"
require 'webmock/rspec'

Dir["#{ Rails.root }/db/seeds/**/*.rb"].each do |file|
  require file
end

Atlas.data_dir = "#{ ::Rails.root }/spec/fixtures/etsource"
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include Paperclip::Shoulda::Matchers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    FactoryGirl.create(:user, email: "robot@quintel.com")
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
