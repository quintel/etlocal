ruby '~> 3.2.0'

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

gem 'virtus'
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

gem 'git'

gem 'transformer', ref: 'cb766b1', github: 'quintel/transformer'
gem 'atlas',       ref: 'd71240e', github: 'quintel/atlas'
gem 'rubel',       ref: 'ad3d44e', github: 'quintel/rubel'
gem 'refinery',    ref: '5439199', github: 'quintel/refinery'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
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
