# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain::ServiceOrders::Status do
  it "permite o fluxo principal" do
    described_class.ensure_transition!("received", "in_diagnosis")
    described_class.ensure_transition!("in_diagnosis", "awaiting_approval")
    described_class.ensure_transition!("awaiting_approval", "in_execution")
    described_class.ensure_transition!("in_execution", "finished")
    described_class.ensure_transition!("finished", "delivered")
  end

  it "permite rejeição do orçamento" do
    described_class.ensure_transition!("awaiting_approval", "in_diagnosis")
  end

  it "bloqueia salto de status" do
    expect { described_class.ensure_transition!("received", "delivered") }
      .to raise_error(Domain::InvalidTransition)
  end
end
