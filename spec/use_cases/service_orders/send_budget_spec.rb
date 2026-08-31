# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCases::ServiceOrders::SendBudget do
  it "recusa orçamento vazio" do
    order = create(:service_order)
    expect { described_class.new(order).call }.to raise_error(Domain::BudgetNotReady)
  end
end
