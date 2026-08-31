# frozen_string_literal: true

require "rails_helper"

RSpec.describe Customer do
  it "normaliza e valida documento" do
    customer = described_class.create!(name: "Ana", document: "529.982.247-25")
    expect(customer.document).to eq("52998224725")
    expect(customer.document_type).to eq("cpf")
  end
end
