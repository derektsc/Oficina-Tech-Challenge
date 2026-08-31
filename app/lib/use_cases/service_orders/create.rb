# frozen_string_literal: true

module UseCases
  module ServiceOrders
    class Create
      def initialize(params)
        @params = params.to_h.with_indifferent_access
      end

      def call
        ActiveRecord::Base.transaction do
          customer = find_or_create_customer
          vehicle = find_or_create_vehicle(customer)
          order = ServiceOrder.create!(
            customer: customer,
            vehicle: vehicle,
            notes: @params[:notes]
          )
          Array(@params[:items]).each { |item| BuildItem.call(order, item) }
          order.recalculate_budget!
          order.reload
        end
      end

      private

      def find_or_create_customer
        if @params[:customer_id].present?
          return Customer.find(@params[:customer_id])
        end

        document = ::Domain::Customers::Document.new(@params[:document] || @params.dig(:customer, :document))
        Customer.find_or_initialize_by(document: document.digits).tap do |customer|
          attrs = (@params[:customer] || {}).slice(:name, :email, :phone)
          attrs[:name] ||= @params[:customer_name]
          customer.assign_attributes(attrs.compact)
          customer.document_type = document.type.to_s
          customer.save!
        end
      end

      def find_or_create_vehicle(customer)
        if @params[:vehicle_id].present?
          vehicle = Vehicle.find(@params[:vehicle_id])
          raise ::Domain::Error, "Veículo não pertence ao cliente" unless vehicle.customer_id == customer.id
          return vehicle
        end

        vehicle_params = @params[:vehicle] || {}
        plate = ::Domain::Vehicles::Plate.new(vehicle_params[:plate] || @params[:plate])
        vehicle = customer.vehicles.find_or_initialize_by(plate: plate.value)
        vehicle.assign_attributes(vehicle_params.slice(:brand, :model, :year))
        vehicle.save!
        vehicle
      end
    end
  end
end
