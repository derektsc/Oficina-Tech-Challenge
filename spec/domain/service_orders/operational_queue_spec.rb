# frozen_string_literal: true

require "rails_helper"

RSpec.describe Domain::ServiceOrders::OperationalQueue do
  it "prioriza execução, aprovação, diagnóstico e recebida" do
    expect(described_class.rank("in_execution")).to be < described_class.rank("awaiting_approval")
    expect(described_class.rank("awaiting_approval")).to be < described_class.rank("in_diagnosis")
    expect(described_class.rank("in_diagnosis")).to be < described_class.rank("received")
  end

  it "esconde finalizadas e entregues da fila operacional" do
    expect(described_class.visible?("finished")).to be(false)
    expect(described_class.visible?("delivered")).to be(false)
    expect(described_class.visible?("in_execution")).to be(true)
  end
end
