# frozen_string_literal: true

FactoryBot.define do
  factory :part do
    sequence(:name) { |n| "Peça #{n}" }
    sequence(:sku) { |n| "SKU-#{n}" }
    unit_price { 40.0 }
    stock_quantity { 10 }
    minimum_stock { 2 }
    active { true }
  end
end
