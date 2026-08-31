# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCases::ServiceOrders::Create do
  it "identifica cliente por CPF e calcula orçamento" do
    service = create(:catalog_service, price: 80)
    part = create(:part, unit_price: 20, stock_quantity: 4)

    order = described_class.new(
      customer: { name: "Pedro", document: "52998224725" },
      vehicle: { plate: "XYZ1A23", brand: "Honda", model: "Civic", year: 2019 },
      items: [
        { item_type: "service", catalog_service_id: service.id },
        { item_type: "part", part_id: part.id, quantity: 2 }
      ]
    ).call

    expect(order.status).to eq("received")
    expect(order.budget_total).to eq(120.to_d)
    expect(order.customer.document).to eq("52998224725")
  end
end
