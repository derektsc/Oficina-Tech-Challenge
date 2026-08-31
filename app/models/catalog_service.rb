# frozen_string_literal: true

class CatalogService < ApplicationRecord
  has_many :service_order_items, dependent: :restrict_with_error

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
