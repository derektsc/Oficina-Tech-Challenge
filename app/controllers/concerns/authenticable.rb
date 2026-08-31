# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    payload = JsonWebToken.decode(token)
    @current_user = User.find(payload[:user_id])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound, TypeError
    render json: { error: "Não autorizado" }, status: :unauthorized
  end

  attr_reader :current_user
end
