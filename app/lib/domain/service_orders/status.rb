# frozen_string_literal: true

module Domain
  module ServiceOrders
    class Status
      RECEIVED = "received"
      IN_DIAGNOSIS = "in_diagnosis"
      AWAITING_APPROVAL = "awaiting_approval"
      IN_EXECUTION = "in_execution"
      FINISHED = "finished"
      DELIVERED = "delivered"

      VALUES = [
        RECEIVED,
        IN_DIAGNOSIS,
        AWAITING_APPROVAL,
        IN_EXECUTION,
        FINISHED,
        DELIVERED
      ].freeze

      LABELS = {
        RECEIVED => "Recebida",
        IN_DIAGNOSIS => "Em diagnóstico",
        AWAITING_APPROVAL => "Aguardando aprovação",
        IN_EXECUTION => "Em execução",
        FINISHED => "Finalizada",
        DELIVERED => "Entregue"
      }.freeze

      TRANSITIONS = {
        RECEIVED => [IN_DIAGNOSIS],
        IN_DIAGNOSIS => [AWAITING_APPROVAL],
        AWAITING_APPROVAL => [IN_EXECUTION, IN_DIAGNOSIS],
        IN_EXECUTION => [FINISHED],
        FINISHED => [DELIVERED],
        DELIVERED => []
      }.freeze

      def self.ensure_transition!(from, to)
        allowed = TRANSITIONS.fetch(from) { [] }
        return if allowed.include?(to)

        raise Domain::InvalidTransition,
              "Transição inválida de #{LABELS[from] || from} para #{LABELS[to] || to}"
      end

      def self.label(status)
        LABELS.fetch(status, status)
      end
    end
  end
end
