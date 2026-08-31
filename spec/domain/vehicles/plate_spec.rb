# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain::Vehicles::Plate do
  it "aceita placa antiga" do
    expect(described_class.new("abc-1234").value).to eq("ABC1234")
  end

  it "aceita placa Mercosul" do
    expect(described_class.new("abc1d23").value).to eq("ABC1D23")
  end

  it "rejeita placa inválida" do
    expect { described_class.new("1234") }.to raise_error(Domain::InvalidPlate)
  end
end
