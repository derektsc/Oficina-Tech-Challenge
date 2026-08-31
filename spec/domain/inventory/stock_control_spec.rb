# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain::Inventory::StockControl do
  it "debita estoque quando há quantidade" do
    part = create(:part, stock_quantity: 5)
    described_class.new(part).debit!(2)
    expect(part.reload.stock_quantity).to eq(3)
  end

  it "bloqueia débito sem estoque" do
    part = create(:part, stock_quantity: 1)
    expect { described_class.new(part).debit!(2) }.to raise_error(Domain::InsufficientStock)
  end
end
