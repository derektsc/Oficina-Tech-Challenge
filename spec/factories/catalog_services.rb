# frozen_string_literal: true

FactoryBot.define do
  factory :catalog_service do
    sequence(:name) { |n| "Serviço #{n}" }
    description { "Serviço de oficina" }
    price { 150.0 }
    active { true }
  end
end
