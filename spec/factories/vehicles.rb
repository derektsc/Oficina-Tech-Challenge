# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    customer
    sequence(:plate) { |n| format("ABC1D%02d", n % 100) }
    brand { "Fiat" }
    model { "Uno" }
    year { 2018 }
  end
end
