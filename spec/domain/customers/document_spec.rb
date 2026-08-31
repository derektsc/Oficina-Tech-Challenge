# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain::Customers::Document do
  it "aceita CPF válido" do
    document = described_class.new("529.982.247-25")
    expect(document.type).to eq(:cpf)
    expect(document.digits).to eq("52998224725")
  end

  it "aceita CNPJ válido" do
    document = described_class.new("11.444.777/0001-61")
    expect(document.type).to eq(:cnpj)
    expect(document.digits).to eq("11444777000161")
  end

  it "rejeita CPF inválido" do
    expect { described_class.new("111.111.111-11") }.to raise_error(Domain::InvalidDocument)
  end

  it "rejeita tamanho incorreto" do
    expect { described_class.new("123") }.to raise_error(Domain::InvalidDocument)
  end
end
