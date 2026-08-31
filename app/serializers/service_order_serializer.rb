# frozen_string_literal: true

class ServiceOrderSerializer
  def initialize(order)
    @order = order
  end

  def as_json(*)
    {
      id: @order.id,
      number: @order.number,
      public_token: @order.public_token,
      status: @order.status,
      status_label: @order.status_label,
      budget_total: @order.budget_total.to_s,
      notes: @order.notes,
      received_at: @order.received_at,
      diagnosis_started_at: @order.diagnosis_started_at,
      budget_sent_at: @order.budget_sent_at,
      approved_at: @order.approved_at,
      rejected_at: @order.rejected_at,
      execution_started_at: @order.execution_started_at,
      finished_at: @order.finished_at,
      delivered_at: @order.delivered_at,
      customer: {
        id: @order.customer.id,
        name: @order.customer.name,
        document: @order.customer.document,
        document_type: @order.customer.document_type
      },
      vehicle: {
        id: @order.vehicle.id,
        plate: @order.vehicle.plate,
        brand: @order.vehicle.brand,
        model: @order.vehicle.model,
        year: @order.vehicle.year
      },
      items: @order.service_order_items.map { |item| ItemSerializer.new(item).as_json }
    }
  end

  class ItemSerializer
    def initialize(item)
      @item = item
    end

    def as_json(*)
      {
        id: @item.id,
        item_type: @item.item_type,
        description: @item.description,
        quantity: @item.quantity,
        unit_price: @item.unit_price.to_s,
        total_price: @item.total_price.to_s,
        catalog_service_id: @item.catalog_service_id,
        part_id: @item.part_id
      }
    end
  end
end
