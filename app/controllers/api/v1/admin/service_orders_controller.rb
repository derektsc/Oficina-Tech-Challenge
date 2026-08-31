# frozen_string_literal: true

class Api::V1::Admin::ServiceOrdersController < Api::V1::Admin::BaseController
  def index
    orders = ServiceOrder.includes(:customer, :vehicle, :service_order_items).order(created_at: :desc)
    orders = orders.where(status: params[:status]) if params[:status].present?
    render json: orders.map { |order| ServiceOrderSerializer.new(order).as_json }
  end

  def show
    render json: ServiceOrderSerializer.new(find_order).as_json
  end

  def create
    order = UseCases::ServiceOrders::Create.new(create_params).call
    render json: ServiceOrderSerializer.new(order).as_json, status: :created
  end

  def update
    order = find_order
    order.update!(notes: params[:notes]) if params.key?(:notes)
    order = UseCases::ServiceOrders::ReplaceItems.new(order, params[:items]).call if params[:items].present?
    render json: ServiceOrderSerializer.new(order.reload).as_json
  end

  def start_diagnosis
    order = UseCases::ServiceOrders::StartDiagnosis.new(find_order).call
    render json: ServiceOrderSerializer.new(order).as_json
  end

  def send_budget
    order = UseCases::ServiceOrders::SendBudget.new(find_order).call
    render json: ServiceOrderSerializer.new(order).as_json
  end

  def finish
    order = UseCases::ServiceOrders::Finish.new(find_order).call
    render json: ServiceOrderSerializer.new(order).as_json
  end

  def deliver
    order = UseCases::ServiceOrders::Deliver.new(find_order).call
    render json: ServiceOrderSerializer.new(order).as_json
  end

  private

  def find_order
    ServiceOrder.includes(:customer, :vehicle, :service_order_items).find(params[:id])
  end

  def create_params
    params.permit(
      :customer_id, :vehicle_id, :document, :customer_name, :notes, :plate,
      customer: %i[name document email phone],
      vehicle: %i[plate brand model year],
      items: %i[item_type type catalog_service_id service_id part_id quantity]
    )
  end
end
