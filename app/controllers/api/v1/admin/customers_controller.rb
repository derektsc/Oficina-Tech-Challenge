# frozen_string_literal: true

class Api::V1::Admin::CustomersController < Api::V1::Admin::BaseController
  def index
    render json: Customer.order(:name)
  end

  def show
    render json: Customer.find(params[:id])
  end

  def create
    customer = Customer.create!(customer_params)
    render json: customer, status: :created
  end

  def update
    customer = Customer.find(params[:id])
    customer.update!(customer_params)
    render json: customer
  end

  def destroy
    Customer.find(params[:id]).destroy!
    head :no_content
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :document, :email, :phone)
  end
end
