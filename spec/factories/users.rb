# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "Admin" }
    sequence(:email) { |n| "admin#{n}@oficina.test" }
    password { "oficina123" }
    role { "admin" }
  end
end
