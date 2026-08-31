# frozen_string_literal: true

module Domain
  module ServiceOrders
    class Budget
      def initialize(items)
        @items = items
      end

      def total
        @items.sum { |item| item.total_price.to_d }
      end

      def ready?
        @items.any?
      end
    end
  end
end
