# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class ApplyExternalBudgetDecision
      DECISIONS = {
        "approved" => ApproveBudget,
        "approve" => ApproveBudget,
        "aprovado" => ApproveBudget,
        "rejected" => RejectBudget,
        "reject" => RejectBudget,
        "recusado" => RejectBudget
      }.freeze

      def initialize(params)
        @params = params.to_h.with_indifferent_access
      end

      def call
        decision = DECISIONS[@params[:decision].to_s.downcase]
        raise ::Domain::Error, "Decisão inválida. Use approved ou rejected" if decision.nil?

        decision.new(find_order).call
      end

      private

      def find_order
        if @params[:public_token].present?
          ServiceOrder.find_by!(public_token: @params[:public_token])
        elsif @params[:number].present? || @params[:service_order_number].present?
          ServiceOrder.find_by!(number: @params[:number].presence || @params[:service_order_number])
        elsif @params[:service_order_id].present? || @params[:id].present?
          ServiceOrder.find(@params[:service_order_id].presence || @params[:id])
        else
          raise ::Domain::Error, "Informe number, public_token ou service_order_id"
        end
      end
    end
  end
end
