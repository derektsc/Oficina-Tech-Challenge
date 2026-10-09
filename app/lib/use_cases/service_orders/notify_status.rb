# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class NotifyStatus
      def self.call(order)
        new(order).call
      end

      def initialize(order)
        @order = order
      end

      def call
        email = @order.customer&.email.to_s.strip
        return if email.empty?

        ServiceOrderMailer.status_updated(@order).deliver_now
      rescue StandardError => error
        Rails.logger.error("Falha ao enviar e-mail da OS #{@order.number}: #{error.class}: #{error.message}")
      end
    end
  end
end
