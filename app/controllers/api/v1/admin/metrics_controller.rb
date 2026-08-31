# frozen_string_literal: true

class Api::V1::Admin::MetricsController < Api::V1::Admin::BaseController
  def average_execution_time
    render json: UseCases::ServiceOrders::AverageExecutionTime.new.call
  end
end
