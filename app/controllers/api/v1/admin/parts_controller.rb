# frozen_string_literal: true

class Api::V1::Admin::PartsController < Api::V1::Admin::BaseController
  def index
    render json: Part.order(:name).map { |part| serialize(part) }
  end

  def show
    render json: serialize(Part.find(params[:id]))
  end

  def create
    part = Part.create!(part_params)
    render json: serialize(part), status: :created
  end

  def update
    part = Part.find(params[:id])
    part.update!(part_params)
    render json: serialize(part)
  end

  def destroy
    Part.find(params[:id]).destroy!
    head :no_content
  end

  private

  def part_params
    params.require(:part).permit(:name, :sku, :unit_price, :stock_quantity, :minimum_stock, :active)
  end

  def serialize(part)
    part.as_json.merge("below_minimum" => part.below_minimum?)
  end
end
