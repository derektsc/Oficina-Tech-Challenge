# frozen_string_literal: true

class Part < ApplicationRecord
  has_many :service_order_items, dependent: :restrict_with_error

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :minimum_stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def below_minimum?
    stock_quantity <= minimum_stock
  end
end
