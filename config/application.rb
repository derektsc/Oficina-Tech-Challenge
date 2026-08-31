require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Oficina
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "America/Sao_Paulo"
    config.active_record.schema_format = :ruby
    config.generators.system_tests = nil
    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") do
      "dev-only-secret-key-base-not-for-production-use-32b"
    end
    config.action_mailer.delivery_method = :test
  end
end
