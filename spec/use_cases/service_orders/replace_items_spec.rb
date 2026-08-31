# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCases::ServiceOrders::ReplaceItems do
  it "substitui itens em diagnóstico e recalcula" do
    order = create(:service_order)
    order.update!(status: "in_diagnosis")
    service = create(:catalog_service, price: 30)

    described_class.new(order, [{ item_type: "service", catalog_service_id: service.id, quantity: 2 }]).call

    expect(order.reload.budget_total).to eq(60.to_d)
    expect(order.service_order_items.count).to eq(1)
  end
end
