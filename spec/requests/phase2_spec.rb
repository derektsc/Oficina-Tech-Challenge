# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Fila operacional, orçamento externo e e-mail", type: :request do
  let(:headers) { auth_headers }
  let(:service) { create(:catalog_service, price: 80) }
  let(:part) { create(:part, unit_price: 20, stock_quantity: 4) }
  let(:integration_headers) { { "X-Integration-Token" => "test-integration-token" } }

  around do |example|
    previous = ENV["INTEGRATION_TOKEN"]
    ENV["INTEGRATION_TOKEN"] = "test-integration-token"
    example.run
  ensure
    ENV["INTEGRATION_TOKEN"] = previous
  end

  def open_order(document: "52998224725", plate: "ABC1D23", email: "joao@example.com")
    post "/api/v1/admin/service_orders",
         params: {
           customer: { name: "João", document: document, email: email },
           vehicle: { plate: plate, brand: "Fiat", model: "Argo", year: 2021 },
           items: [
             { item_type: "service", catalog_service_id: service.id, quantity: 1 },
             { item_type: "part", part_id: part.id, quantity: 1 }
           ]
         },
         headers: headers,
         as: :json
    json_body
  end

  def await_budget(order)
    post "/api/v1/admin/service_orders/#{order["id"]}/start_diagnosis", headers: headers
    post "/api/v1/admin/service_orders/#{order["id"]}/send_budget", headers: headers
  end

  it "lista a fila operacional por prioridade de status e mais antigas primeiro" do
    older_execution = create(:service_order)
    newer_execution = create(:service_order)
    older_approval = create(:service_order)
    diagnosis = create(:service_order)
    older_received = create(:service_order)
    newer_received = create(:service_order)
    finished = create(:service_order)
    delivered = create(:service_order)

    older_execution.update_columns(status: "in_execution", received_at: 5.hours.ago)
    newer_execution.update_columns(status: "in_execution", received_at: 1.hour.ago)
    older_approval.update_columns(status: "awaiting_approval", received_at: 4.hours.ago)
    diagnosis.update_columns(status: "in_diagnosis", received_at: 3.hours.ago)
    older_received.update_columns(status: "received", received_at: 6.hours.ago)
    newer_received.update_columns(status: "received", received_at: 30.minutes.ago)
    finished.update_columns(status: "finished", received_at: 2.days.ago)
    delivered.update_columns(status: "delivered", received_at: 3.days.ago)

    get "/api/v1/admin/service_orders", headers: headers

    expect(response).to have_http_status(:ok)
    expect(json_body.map { |order| order["id"] }).to eq([
      older_execution.id,
      newer_execution.id,
      older_approval.id,
      diagnosis.id,
      older_received.id,
      newer_received.id
    ])
    expect(json_body.map { |order| order["status"] }).not_to include("finished", "delivered")
  end

  it "envia e-mail quando o status da OS muda" do
    order = open_order
    ActionMailer::Base.deliveries.clear

    post "/api/v1/admin/service_orders/#{order["id"]}/start_diagnosis", headers: headers

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(["joao@example.com"])
    expect(mail.subject).to include(order["number"])
    expect(mail.subject).to include("Em diagnóstico")
    expect(mail.body.encoded).to include("ABC1D23")
  end

  it "aprova o orçamento por notificação externa e debita o estoque" do
    order = open_order
    await_budget(order)

    post "/api/v1/integrations/budget_notifications",
         params: { number: order["number"], decision: "approved", external_reference: "crm-100" },
         headers: integration_headers,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(json_body["status"]).to eq("in_execution")
    expect(part.reload.stock_quantity).to eq(3)
    expect(ActionMailer::Base.deliveries.map(&:subject).join).to include("Em execução")
  end

  it "recusa o orçamento pelo token público" do
    order = open_order(document: "39053344705", plate: "DEF2E34", email: "ana@example.com")
    await_budget(order)

    post "/api/v1/integrations/budget_notifications",
         params: { public_token: order["public_token"], decision: "rejected" },
         headers: integration_headers,
         as: :json

    expect(json_body["status"]).to eq("in_diagnosis")
    expect(part.reload.stock_quantity).to eq(4)
  end

  it "aceita a notificação pelo id da OS" do
    order = open_order(document: "15350946056", plate: "GHI3F45")
    await_budget(order)

    post "/api/v1/integrations/budget_notifications",
         params: { service_order_id: order["id"], decision: "approved" },
         headers: integration_headers,
         as: :json

    expect(response).to have_http_status(:ok)
    expect(json_body["status"]).to eq("in_execution")
  end

  it "recusa token ausente, decisão inválida e OS sem identificador" do
    post "/api/v1/integrations/budget_notifications", params: { decision: "approved" }, as: :json
    expect(response).to have_http_status(:unauthorized)

    post "/api/v1/integrations/budget_notifications",
         params: { decision: "talvez" },
         headers: integration_headers,
         as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(json_body["error"]).to include("Decisão inválida")

    post "/api/v1/integrations/budget_notifications",
         params: { decision: "approved" },
         headers: integration_headers,
         as: :json
    expect(response).to have_http_status(:unprocessable_content)
    expect(json_body["error"]).to include("Informe number")
  end
end
