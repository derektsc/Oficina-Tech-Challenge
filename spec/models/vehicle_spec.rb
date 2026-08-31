# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vehicle do
  it "normaliza placa Mercosul" do
    customer = create(:customer)
    vehicle = described_class.create!(customer: customer, plate: "abc1d23", brand: "VW", model: "Polo", year: 2022)
    expect(vehicle.plate).to eq("ABC1D23")
  end
end
