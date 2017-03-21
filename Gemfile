source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'mysql2'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.0.1'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

gem 'slim'
gem 'paperclip'
gem 'devise'
gem 'pundit'
gem 'validates_email_format_of'

gem 'atlas',    ref: 'c736be3', github: 'quintel/atlas'
gem 'rubel',    ref: 'ad3d44e', github: 'quintel/rubel'
gem 'refinery', ref: '636686c', github: 'quintel/refinery'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'pry'
  gem 'dotenv-rails'

  gem 'capistrano',             '~> 3.0',   require: false
  gem 'capistrano-rbenv',       '~> 2.0',   require: false
  gem 'capistrano-rails',       '~> 1.1',   require: false
  gem 'capistrano-bundler',     '~> 1.1',   require: false
  gem 'capistrano3-unicorn',    '~> 0.2',   require: false
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'webmock'
end

group :development do
  gem 'rest-client'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production, :staging do
  gem 'unicorn'
  gem 'airbrake'
end

gem 'therubyracer'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
