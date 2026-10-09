# frozen_string_literal: true

module Domain
  module ServiceOrders
    class OperationalQueue
      EXCLUDED = [
        Status::FINISHED,
        Status::DELIVERED
      ].freeze

      PRIORITY = [
        Status::IN_EXECUTION,
        Status::AWAITING_APPROVAL,
        Status::IN_DIAGNOSIS,
        Status::RECEIVED
      ].freeze

      def self.rank(status)
        index = PRIORITY.index(status)
        index.nil? ? PRIORITY.length : index
      end

      def self.visible?(status)
        !EXCLUDED.include?(status)
      end
    end
  end
end
