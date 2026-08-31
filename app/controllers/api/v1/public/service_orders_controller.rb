# frozen_string_literal: true

class Api::V1::Public::ServiceOrdersController < ApplicationController
  def index
    document = params[:document]
    raise ::Domain::Error, "Informe o CPF/CNPJ" if document.blank?

    ::Domain::Customers::Document.new(document)
    orders = ServiceOrder.by_document(document).includes(:customer, :vehicle, :service_order_items)
    render json: orders.map { |order| public_payload(order) }
  end

  def show
    render json: public_payload(find_order)
  end

  def approve
    order = UseCases::ServiceOrders::ApproveBudget.new(find_order).call
    render json: public_payload(order)
  end

  def reject
    order = UseCases::ServiceOrders::RejectBudget.new(find_order).call
    render json: public_payload(order)
  end

  private

  def find_order
    ServiceOrder.includes(:customer, :vehicle, :service_order_items).find_by!(public_token: params[:public_token])
  end

  def public_payload(order)
    ServiceOrderSerializer.new(order).as_json
  end
end
