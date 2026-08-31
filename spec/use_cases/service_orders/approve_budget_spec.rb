# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCases::ServiceOrders::ApproveBudget do
  it "não aprova se o estoque ficou insuficiente" do
    customer = create(:customer)
    vehicle = create(:vehicle, customer: customer)
    part = create(:part, stock_quantity: 1)
    order = create(:service_order, customer: customer, vehicle: vehicle, status: "awaiting_approval")
    order.service_order_items.create!(
      item_type: "part",
      part: part,
      description: part.name,
      quantity: 2,
      unit_price: part.unit_price
    )
    part.update!(stock_quantity: 0)

    expect { described_class.new(order).call }.to raise_error(Domain::InsufficientStock)
  end
end
