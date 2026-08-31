# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class SendBudget
      def initialize(order)
        @order = order
      end

      def call
        raise ::Domain::BudgetNotReady, "Inclua serviços ou peças antes de enviar o orçamento" unless @order.budget.ready?

        @order.recalculate_budget!
        @order.transition_to!(::Domain::ServiceOrders::Status::AWAITING_APPROVAL)
        @order
      end
    end
  end
end
