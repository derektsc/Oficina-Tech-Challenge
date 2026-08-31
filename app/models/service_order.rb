# frozen_string_literal: true

class ServiceOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :vehicle
  has_many :service_order_items, dependent: :destroy

  validates :number, :public_token, :status, presence: true
  validates :number, uniqueness: true
  validates :public_token, uniqueness: true
  validates :status, inclusion: { in: ::Domain::ServiceOrders::Status::VALUES }
  validate :vehicle_belongs_to_customer

  before_validation :assign_defaults, on: :create

  scope :by_document, ->(document) {
    digits = document.to_s.gsub(/\D/, "")
    joins(:customer).where(customers: { document: digits })
  }

  def budget
    ::Domain::ServiceOrders::Budget.new(service_order_items)
  end

  def recalculate_budget!
    update!(budget_total: budget.total)
  end

  def status_label
    ::Domain::ServiceOrders::Status.label(status)
  end

  def execution_duration_seconds
    return if execution_started_at.blank? || finished_at.blank?

    (finished_at - execution_started_at).to_i
  end

  def transition_to!(new_status)
    ::Domain::ServiceOrders::Status.ensure_transition!(status, new_status)
    self.status = new_status
    stamp_timestamp!(new_status)
    save!
  end

  private

  def assign_defaults
    self.public_token ||= SecureRandom.uuid
    self.number ||= next_number
    self.status ||= ::Domain::ServiceOrders::Status::RECEIVED
    self.received_at ||= Time.current
    self.budget_total ||= 0
  end

  def next_number
    date = Time.current.strftime("%Y%m%d")
    sequence = self.class.where("number LIKE ?", "OS-#{date}-%").count + 1
    format("OS-%<date>s-%<seq>04d", date: date, seq: sequence)
  end

  def stamp_timestamp!(new_status)
    now = Time.current
    case new_status
    when ::Domain::ServiceOrders::Status::IN_DIAGNOSIS
      self.diagnosis_started_at ||= now
    when ::Domain::ServiceOrders::Status::AWAITING_APPROVAL
      self.budget_sent_at = now
    when ::Domain::ServiceOrders::Status::IN_EXECUTION
      self.approved_at = now
      self.execution_started_at ||= now
    when ::Domain::ServiceOrders::Status::FINISHED
      self.finished_at = now
    when ::Domain::ServiceOrders::Status::DELIVERED
      self.delivered_at = now
    end
  end

  def vehicle_belongs_to_customer
    return if vehicle.blank? || customer.blank?
    return if vehicle.customer_id == customer_id

    errors.add(:vehicle, "não pertence ao cliente informado")
  end
end
