ruby '3.3.5'

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap', require: false

gem 'jbuilder'
gem 'jquery-rails', '>= 1.0.3'
gem 'mysql2'
gem 'puma'
gem 'rails', '~> 7.0'
gem 'rails-i18n'
gem 'sass-rails'
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'
gem 'http_accept_language'

gem 'ostruct'
gem 'dry-struct'
gem 'dry-types'
gem 'slim'
gem 'pundit'
gem 'devise'
gem 'rest-client'
gem 'validates_email_format_of'
gem 'gradients'
gem 'tty-progressbar'
gem 'remotipart', '~> 1.2'
gem 'archive-zip', '~> 0.9.0'
gem 'sentry-raven'
gem 'deep_cloneable'
gem 'str_enum'
gem 'config'

gem 'git'

gem 'transformer', ref: '8669dd1', github: 'quintel/transformer'
gem 'atlas',       ref: 'b3ef5c8', github: 'quintel/atlas'
gem 'rubel',       ref: 'ad3d44e', github: 'quintel/rubel'
gem 'refinery',    ref: '5439199', github: 'quintel/refinery'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '6.1.1'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'capybara',        '3.40.0'
  gem 'selenium-webdriver','4.10'
  gem 'rails-controller-testing'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'webmock'
  gem 'timecop'
  gem 'simplecov', require: false
  gem 'rspec_junit_formatter', require: false
end

group :development do
  gem 'listen'
  gem 'spring'
  gem 'web-console', '>= 3.3.0'

  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

gem 'mini_racer', '~> 0.6.3'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
