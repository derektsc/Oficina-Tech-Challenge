# frozen_string_literal: true

class Api::V1::Integrations::BudgetNotificationsController < ApplicationController
  before_action :authenticate_integration!

  def create
    order = UseCases::ServiceOrders::ApplyExternalBudgetDecision.new(notification_params).call
    render json: ServiceOrderSerializer.new(order).as_json
  end

  private

  def authenticate_integration!
    return if integration_token_valid?

    render json: { error: "Token de integração inválido" }, status: :unauthorized
  end

  def integration_token_valid?
    provided = request.headers["X-Integration-Token"].to_s
    expected = ENV["INTEGRATION_TOKEN"].to_s
    return false if provided.empty? || expected.empty? || provided.bytesize != expected.bytesize

    ActiveSupport::SecurityUtils.secure_compare(provided, expected)
  end

  def notification_params
    params.permit(:decision, :number, :service_order_number, :public_token, :service_order_id, :id, :external_reference)
  end
end
