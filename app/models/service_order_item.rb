# frozen_string_literal: true

class ServiceOrderItem < ApplicationRecord
  belongs_to :service_order
  belongs_to :catalog_service, optional: true
  belongs_to :part, optional: true

  validates :item_type, inclusion: { in: %w[service part] }
  validates :description, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, :total_price, numericality: { greater_than_or_equal_to: 0 }
  validate :consistent_item_reference

  before_validation :compute_total

  private

  def compute_total
    self.total_price = quantity.to_i * unit_price.to_d if quantity.present? && unit_price.present?
  end

  def consistent_item_reference
    case item_type
    when "service"
      errors.add(:catalog_service, "é obrigatório") if catalog_service_id.blank?
    when "part"
      errors.add(:part, "é obrigatório") if part_id.blank?
    end
  end
end
