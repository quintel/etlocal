ruby '2.6.6'

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'bootsnap', require: false

gem 'jbuilder', '~> 2.5'
gem 'jquery-rails', '>= 1.0.3'
gem 'mysql2'
gem 'puma', '< 5'
gem 'rails', '~> 5.2'
gem 'rails-i18n', '~> 5.1'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
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
gem 'deep_cloneable', '~> 2.3.0'

gem 'git'

gem 'transformer', ref: '721f8f0', github: 'quintel/transformer'
gem 'atlas',       ref: '0546b99', github: 'quintel/atlas'
gem 'rubel',       ref: 'ad3d44e', github: 'quintel/rubel'
gem 'refinery',    ref: '72eacf8', github: 'quintel/refinery'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'dotenv-rails'

  gem 'capistrano',         '~> 3.0',   require: false
  gem 'capistrano-rbenv',   '~> 2.0',   require: false
  gem 'capistrano-rails',   '~> 1.1',   require: false
  gem 'capistrano-bundler', '~> 1.1',   require: false
  gem 'capistrano3-puma',   '~> 5.0.4', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'webmock'
  gem 'timecop'
  gem 'simplecov', require: false
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

gem 'mini_racer'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
