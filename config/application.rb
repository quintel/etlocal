require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Etlocal
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Etc/UTC"
    # config.eager_load_paths << Rails.root.join("extras")

    config.encoding             = "utf-8"
    config.assumptions_path     = Rails.root.join("config", "assumptions.yml")
    config.etsource_path        = Rails.root.dirname.join("etsource").to_s
    config.google_maps_api_key  = Rails.application.secrets.google_maps_api_key

    config.i18n.default_locale    = :en
    config.i18n.fallbacks         = [:en]
    config.i18n.available_locales = %i[en nl]
  end
end
