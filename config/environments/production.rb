require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = true
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.require_master_key = false
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")
  config.hosts.clear
  config.assume_ssl = false
  config.force_ssl = false
  config.action_mailer.raise_delivery_errors = false
  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(logger)
end
