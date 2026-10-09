# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class StartDiagnosis
      def initialize(order)
        @order = order
      end

      def call
        @order.transition_to!(::Domain::ServiceOrders::Status::IN_DIAGNOSIS)
        NotifyStatus.call(@order)
        @order
      end
    end
  end
end
