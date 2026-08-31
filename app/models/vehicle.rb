# frozen_string_literal: true

class Vehicle < ApplicationRecord
  belongs_to :customer
  has_many :service_orders, dependent: :restrict_with_error

  validates :plate, presence: true, uniqueness: true
  validates :brand, :model, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than: 1950, less_than: 2100 }

  before_validation :normalize_plate

  private

  def normalize_plate
    return if plate.blank?

    parsed = ::Domain::Vehicles::Plate.new(plate)
    self.plate = parsed.value
  rescue ::Domain::InvalidPlate => e
    errors.add(:plate, e.message)
  end
end
