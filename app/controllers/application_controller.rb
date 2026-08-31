# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
  rescue_from ::Domain::Error, with: :domain_error
  rescue_from ActiveRecord::RecordNotDestroyed, with: :unprocessable_destroy

  private

  def not_found
    render json: { error: "Recurso não encontrado" }, status: :not_found
  end

  def unprocessable(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_content
  end

  def domain_error(exception)
    render json: { error: exception.message }, status: :unprocessable_content
  end

  def unprocessable_destroy(exception)
    render json: { error: exception.record.errors.full_messages.presence || exception.message },
           status: :unprocessable_content
  end
end
