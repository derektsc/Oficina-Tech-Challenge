# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin CRUD", type: :request do
  let(:headers) { auth_headers }

  it "cria e lista clientes com CPF válido" do
    post "/api/v1/admin/customers",
         params: { customer: { name: "Ana", document: "52998224725", email: "ana@example.com" } },
         headers: headers

    expect(response).to have_http_status(:created)

    get "/api/v1/admin/customers", headers: headers
    expect(json_body.length).to eq(1)
  end

  it "rejeita CPF inválido" do
    post "/api/v1/admin/customers",
         params: { customer: { name: "Ana", document: "11111111111" } },
         headers: headers

    expect(response).to have_http_status(:unprocessable_content)
  end

  it "faz CRUD de veículo, serviço e peça" do
    customer = create(:customer)

    post "/api/v1/admin/vehicles",
         params: { vehicle: { customer_id: customer.id, plate: "ABC1234", brand: "VW", model: "Gol", year: 2020 } },
         headers: headers
    expect(response).to have_http_status(:created)

    post "/api/v1/admin/catalog_services",
         params: { catalog_service: { name: "Troca de óleo", price: 180 } },
         headers: headers
    expect(response).to have_http_status(:created)

    post "/api/v1/admin/parts",
         params: { part: { name: "Filtro", sku: "FIL-1", unit_price: 40, stock_quantity: 8, minimum_stock: 2 } },
         headers: headers
    expect(response).to have_http_status(:created)
    expect(json_body["below_minimum"]).to eq(false)
  end
end
