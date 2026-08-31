# frozen_string_literal: true

require "rails_helper"

RSpec.describe ServiceOrder do
  it "atribui número e token públicos" do
    order = create(:service_order)
    expect(order.number).to start_with("OS-")
    expect(order.public_token).to be_present
    expect(order.status).to eq("received")
  end
end
