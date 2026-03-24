ruby '~> 4.0.2'

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
gem 'rails', '~> 8.1'
gem 'rails-i18n'
gem 'sassc-rails'
gem 'turbolinks'
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

gem 'transformer', ref: '0e5c5fd', github: 'quintel/transformer'
gem 'atlas',       ref: 'f0fb6be', github: 'quintel/atlas'
gem 'rubel',       ref: '9fe7010', github: 'quintel/rubel'
gem 'refinery',    ref: '36b8e34', github: 'quintel/refinery'

group :development, :test do
  gem 'binding_of_caller', '~> 2.0.0'
  gem 'pry-byebug', '~> 3.12.0', platform: :mri
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~> 8.0'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'capybara',        '~> 3.40'
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

gem 'mini_racer'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
