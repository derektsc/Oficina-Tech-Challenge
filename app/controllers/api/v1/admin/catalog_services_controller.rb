# frozen_string_literal: true

class Api::V1::Admin::CatalogServicesController < Api::V1::Admin::BaseController
  def index
    render json: CatalogService.order(:name)
  end

  def show
    render json: CatalogService.find(params[:id])
  end

  def create
    service = CatalogService.create!(catalog_service_params)
    render json: service, status: :created
  end

  def update
    service = CatalogService.find(params[:id])
    service.update!(catalog_service_params)
    render json: service
  end

  def destroy
    CatalogService.find(params[:id]).destroy!
    head :no_content
  end

  private

  def catalog_service_params
    params.require(:catalog_service).permit(:name, :description, :price, :active)
  end
end
