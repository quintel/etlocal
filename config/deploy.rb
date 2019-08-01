# config valid only for current version of Capistrano
lock "3.11.0"

set :log_level, 'info'

set :application, "etlocal"
set :repo_url, "git@github.com:quintel/etlocal.git"

# Set up rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.6.3'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

set :bundle_binstubs, (-> { shared_path.join('sbin') })

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/email.yml", "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "sbin", "log", "tmp/pids", "tmp/cache", "vendor/bundle", "public/system"

namespace :deploy do
  after :finishing, 'deploy:etsource'
  after :publishing, :restart
end

# Puma Options
# ============
# If these are changed, be sure to then run `cap $stage puma:config`; the config
# on the server is not automatically updated when deploying.

set :puma_init_active_record, true
set :puma_preload_app, true
