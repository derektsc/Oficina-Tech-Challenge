# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class BuildItem
      def self.call(order, raw)
        item = raw.to_h.with_indifferent_access
        type = item[:item_type].presence || item[:type]
        quantity = (item[:quantity] || 1).to_i

        case type.to_s
        when "service"
          service = CatalogService.find(item[:catalog_service_id] || item[:service_id])
          order.service_order_items.create!(
            item_type: "service",
            catalog_service: service,
            description: service.name,
            quantity: quantity,
            unit_price: service.price
          )
        when "part"
          part = Part.find(item[:part_id])
          ::Domain::Inventory::StockControl.new(part).ensure_available!(quantity)
          order.service_order_items.create!(
            item_type: "part",
            part: part,
            description: part.name,
            quantity: quantity,
            unit_price: part.unit_price
          )
        else
          raise ::Domain::Error, "Tipo de item inválido: #{type}"
        end
      end
    end
  end
end
