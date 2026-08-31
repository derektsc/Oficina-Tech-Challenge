# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class ApproveBudget
      def initialize(order)
        @order = order
      end

      def call
        ActiveRecord::Base.transaction do
          debit_parts!
          @order.transition_to!(::Domain::ServiceOrders::Status::IN_EXECUTION)
          @order
        end
      end

      private

      def debit_parts!
        @order.service_order_items.where(item_type: "part").find_each do |item|
          part = Part.lock.find(item.part_id)
          ::Domain::Inventory::StockControl.new(part).debit!(item.quantity)
        end
      end
    end
  end
end
