# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class ListOperational
      def initialize(status: nil)
        @status = status.presence
      end

      def call
        scope = ServiceOrder
                .includes(:customer, :vehicle, :service_order_items)
                .operational
        scope = scope.where(status: @status) if @status
        scope.order(Arel.sql(order_sql))
      end

      private

      def order_sql
        queue = ::Domain::ServiceOrders::OperationalQueue
        branches = queue::PRIORITY.each_with_index.map { |status, index| "WHEN '#{status}' THEN #{index}" }
        <<~SQL.squish
          CASE service_orders.status #{branches.join(" ")} ELSE #{queue::PRIORITY.length} END ASC,
          service_orders.received_at ASC NULLS LAST,
          service_orders.id ASC
        SQL
      end
    end
  end
end
