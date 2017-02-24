require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Etlocal
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone           = "Europe/Amsterdam"

    config.encoding            = "utf-8"
    config.etsource_path       = Rails.root.dirname.join("etsource").to_s
    config.google_maps_api_key = Rails.application.secrets.google_maps_api_key
  end
end
