# frozen_string_literal: true

class ServiceOrderMailer < ApplicationMailer
  def status_updated(order)
    @order = order
    mail(
      to: order.customer.email,
      subject: "OS #{order.number}: #{order.status_label}"
    )
  end
end
