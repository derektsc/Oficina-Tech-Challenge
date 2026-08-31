# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :vehicles, dependent: :restrict_with_error
  has_many :service_orders, dependent: :restrict_with_error

  validates :name, presence: true
  validates :document, presence: true, uniqueness: true
  validates :document_type, inclusion: { in: %w[cpf cnpj] }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :normalize_document

  def document_object
    ::Domain::Customers::Document.new(document)
  end

  private

  def normalize_document
    return if document.blank?

    parsed = ::Domain::Customers::Document.new(document)
    self.document = parsed.digits
    self.document_type = parsed.type.to_s
  rescue ::Domain::InvalidDocument => e
    errors.add(:document, e.message)
  end
end
