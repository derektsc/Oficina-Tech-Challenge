# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class RejectBudget
      def initialize(order)
        @order = order
      end

      def call
        @order.rejected_at = Time.current
        @order.transition_to!(::Domain::ServiceOrders::Status::IN_DIAGNOSIS)
        @order
      end
    end
  end
end
