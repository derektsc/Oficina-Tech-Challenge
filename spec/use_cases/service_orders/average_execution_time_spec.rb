# frozen_string_literal: true

require "rails_helper"

RSpec.describe UseCases::ServiceOrders::AverageExecutionTime do
  it "calcula média quando há OS finalizadas" do
    order = create(:service_order)
    order.update!(
      status: "finished",
      execution_started_at: 2.hours.ago,
      finished_at: Time.current
    )

    result = described_class.new.call
    expect(result[:sample_size]).to eq(1)
    expect(result[:average_execution_seconds]).to be_within(5).of(2.hours.to_i)
  end

  it "retorna nulo sem amostra" do
    result = described_class.new.call
    expect(result[:sample_size]).to eq(0)
    expect(result[:average_execution_seconds]).to be_nil
  end
end
