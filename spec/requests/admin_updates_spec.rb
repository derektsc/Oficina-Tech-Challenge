# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin updates", type: :request do
  let(:headers) { auth_headers }

  it "atualiza e remove cadastros sem vínculo" do
    post "/api/v1/admin/customers",
         params: { customer: { name: "Ana", document: "52998224725" } },
         headers: headers
    customer_id = json_body["id"]

    patch "/api/v1/admin/customers/#{customer_id}",
          params: { customer: { name: "Ana Lima" } },
          headers: headers
    expect(json_body["name"]).to eq("Ana Lima")

    post "/api/v1/admin/catalog_services",
         params: { catalog_service: { name: "Balanceamento", price: 90 } },
         headers: headers
    service_id = json_body["id"]
    patch "/api/v1/admin/catalog_services/#{service_id}",
          params: { catalog_service: { price: 95 } },
          headers: headers
    expect(json_body["price"]).to eq("95.0")

    delete "/api/v1/admin/catalog_services/#{service_id}", headers: headers
    expect(response).to have_http_status(:no_content)

    post "/api/v1/admin/parts",
         params: { part: { name: "Pastilha", sku: "PAS-1", unit_price: 70, stock_quantity: 3 } },
         headers: headers
    part_id = json_body["id"]
    patch "/api/v1/admin/parts/#{part_id}",
          params: { part: { stock_quantity: 1, minimum_stock: 2 } },
          headers: headers
    expect(json_body["below_minimum"]).to eq(true)

    delete "/api/v1/admin/parts/#{part_id}", headers: headers
    expect(response).to have_http_status(:no_content)

    delete "/api/v1/admin/customers/#{customer_id}", headers: headers
    expect(response).to have_http_status(:no_content)
  end
end
