# frozen_string_literal: true

unless Rails.env.test? || ENV["SMTP_ADDRESS"].blank?
  settings = {
    address: ENV["SMTP_ADDRESS"],
    port: ENV.fetch("SMTP_PORT", "1025").to_i,
    enable_starttls_auto: ENV["SMTP_STARTTLS"] == "true"
  }

  if ENV["SMTP_USER"].present?
    settings[:user_name] = ENV["SMTP_USER"]
    settings[:password] = ENV["SMTP_PASSWORD"]
    settings[:authentication] = :plain
  end

  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = settings
  Rails.application.config.action_mailer.perform_deliveries = true
  Rails.application.config.action_mailer.raise_delivery_errors = ENV["SMTP_RAISE_ERRORS"] == "true"
end
