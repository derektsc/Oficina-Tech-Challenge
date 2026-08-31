# frozen_string_literal: true

class JsonWebToken
  def self.encode(payload, exp = 24.hours.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret)[0]
    HashWithIndifferentAccess.new(decoded)
  end

  def self.secret
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
  private_class_method :secret
end
