# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class AverageExecutionTime
      def call
        durations = ServiceOrder.where.not(execution_started_at: nil, finished_at: nil).filter_map(&:execution_duration_seconds)
        sample = durations.size
        average = sample.positive? ? (durations.sum.to_f / sample).round : nil

        {
          sample_size: sample,
          average_execution_seconds: average,
          average_execution_human: humanize(average)
        }
      end

      private

      def humanize(seconds)
        return nil if seconds.nil?

        hours = seconds / 3600
        minutes = (seconds % 3600) / 60
        "#{hours}h #{minutes}min"
      end
    end
  end
end
