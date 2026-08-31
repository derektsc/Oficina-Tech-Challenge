# frozen_string_literal: true

class Api::V1::Admin::VehiclesController < Api::V1::Admin::BaseController
  def index
    scope = Vehicle.includes(:customer)
    scope = scope.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    render json: scope.order(:plate)
  end

  def show
    render json: Vehicle.find(params[:id])
  end

  def create
    vehicle = Vehicle.create!(vehicle_params)
    render json: vehicle, status: :created
  end

  def update
    vehicle = Vehicle.find(params[:id])
    vehicle.update!(vehicle_params)
    render json: vehicle
  end

  def destroy
    Vehicle.find(params[:id]).destroy!
    head :no_content
  end

  private

  def vehicle_params
    params.require(:vehicle).permit(:customer_id, :plate, :brand, :model, :year)
  end
end
