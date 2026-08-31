# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { "Cliente Teste" }
    document { CPFGenerator.next }
    email { "cliente@example.com" }
    phone { "11988887777" }
  end
end
