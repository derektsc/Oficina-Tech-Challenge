# frozen_string_literal: true

class Api::V1::AuthController < ApplicationController
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token, user: { id: user.id, name: user.name, email: user.email } }
    else
      render json: { error: "Credenciais inválidas" }, status: :unauthorized
    end
  end
end
