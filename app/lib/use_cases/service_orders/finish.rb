# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class Finish
      def initialize(order)
        @order = order
      end

      def call
        @order.transition_to!(::Domain::ServiceOrders::Status::FINISHED)
        NotifyStatus.call(@order)
        @order
      end
    end
  end
end
