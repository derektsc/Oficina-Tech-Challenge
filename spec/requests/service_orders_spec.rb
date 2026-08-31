# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Fluxo da ordem de serviço", type: :request do
  let(:headers) { auth_headers }
  let(:service) { create(:catalog_service, name: "Alinhamento", price: 100) }
  let(:part) { create(:part, name: "Filtro", unit_price: 50, stock_quantity: 5) }

  def create_order
    post "/api/v1/admin/service_orders",
         params: {
           customer: { name: "João", document: "52998224725", email: "joao@example.com" },
           vehicle: { plate: "ABC1D23", brand: "Fiat", model: "Argo", year: 2021 },
           items: [
             { item_type: "service", catalog_service_id: service.id, quantity: 1 },
             { item_type: "part", part_id: part.id, quantity: 2 }
           ]
         },
         headers: headers
  end

  it "gera orçamento e percorre o ciclo de vida com aprovação do cliente" do
    create_order
    expect(response).to have_http_status(:created)
    order = json_body
    expect(order["status"]).to eq("received")
    expect(order["budget_total"]).to eq("200.0")
    token = order["public_token"]
    id = order["id"]

    post "/api/v1/admin/service_orders/#{id}/start_diagnosis", headers: headers
    expect(json_body["status"]).to eq("in_diagnosis")

    post "/api/v1/admin/service_orders/#{id}/send_budget", headers: headers
    expect(json_body["status"]).to eq("awaiting_approval")

    get "/api/v1/public/service_orders/#{token}"
    expect(response).to have_http_status(:ok)
    expect(json_body["status_label"]).to eq("Aguardando aprovação")

    get "/api/v1/public/service_orders", params: { document: "52998224725" }
    expect(json_body.length).to eq(1)

    post "/api/v1/public/service_orders/#{token}/approve"
    expect(json_body["status"]).to eq("in_execution")
    expect(part.reload.stock_quantity).to eq(3)

    post "/api/v1/admin/service_orders/#{id}/finish", headers: headers
    expect(json_body["status"]).to eq("finished")

    post "/api/v1/admin/service_orders/#{id}/deliver", headers: headers
    expect(json_body["status"]).to eq("delivered")

    get "/api/v1/admin/metrics/average_execution_time", headers: headers
    expect(json_body["sample_size"]).to eq(1)
    expect(json_body["average_execution_seconds"]).to be >= 0
  end

  it "devolve a OS para diagnóstico quando o cliente rejeita" do
    create_order
    id = json_body["id"]
    token = json_body["public_token"]

    post "/api/v1/admin/service_orders/#{id}/start_diagnosis", headers: headers
    post "/api/v1/admin/service_orders/#{id}/send_budget", headers: headers
    post "/api/v1/public/service_orders/#{token}/reject"

    expect(json_body["status"]).to eq("in_diagnosis")
    expect(part.reload.stock_quantity).to eq(5)
  end

  it "impede envio de orçamento sem itens" do
    customer = create(:customer)
    vehicle = create(:vehicle, customer: customer)
    post "/api/v1/admin/service_orders",
         params: { customer_id: customer.id, vehicle_id: vehicle.id },
         headers: headers
    id = json_body["id"]
    post "/api/v1/admin/service_orders/#{id}/start_diagnosis", headers: headers
    post "/api/v1/admin/service_orders/#{id}/send_budget", headers: headers
    expect(response).to have_http_status(:unprocessable_content)
  end
end
