# frozen_string_literal: true

FactoryBot.define do
  factory :service_order do
    customer
    vehicle { association :vehicle, customer: customer }
    notes { "Revisão periódica" }
  end
end
