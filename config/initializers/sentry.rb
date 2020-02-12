# frozen_string_literal: true

Raven.configure do |config|
  config.dsn = Rails.application.secrets.sentry_dsn
  config.environments = %w[production staging]

  config.sanitize_fields =
    Rails.application.config.filter_parameters.map(&:to_s)
end
