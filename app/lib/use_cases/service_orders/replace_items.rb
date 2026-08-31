# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class ReplaceItems
      def initialize(order, items)
        @order = order
        @items = Array(items)
      end

      def call
        unless %w[received in_diagnosis].include?(@order.status)
          raise ::Domain::Error, "Itens só podem ser alterados antes do envio do orçamento"
        end

        ActiveRecord::Base.transaction do
          @order.service_order_items.destroy_all
          @items.each { |item| BuildItem.call(@order, item) }
          @order.recalculate_budget!
          @order.reload
        end
      end
    end
  end
end
