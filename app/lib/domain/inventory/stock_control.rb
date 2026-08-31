# frozen_string_literal: true

module Domain
  module Inventory
    class StockControl
      def initialize(part)
        @part = part
      end

      def ensure_available!(quantity)
        return if @part.stock_quantity >= quantity

        raise Domain::InsufficientStock,
              "Estoque insuficiente para #{@part.name} (disponível: #{@part.stock_quantity})"
      end

      def debit!(quantity)
        ensure_available!(quantity)
        @part.update!(stock_quantity: @part.stock_quantity - quantity)
      end

      def credit!(quantity)
        @part.update!(stock_quantity: @part.stock_quantity + quantity)
      end
    end
  end
end
