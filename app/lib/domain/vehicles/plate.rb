# frozen_string_literal: true

module Domain
  module Vehicles
    class Plate
      OLD_FORMAT = /\A[A-Z]{3}\d{4}\z/
      MERCOSUL_FORMAT = /\A[A-Z]{3}\d[A-Z]\d{2}\z/

      attr_reader :value

      def initialize(raw)
        @value = raw.to_s.upcase.gsub(/[^A-Z0-9]/, "")
        raise Domain::InvalidPlate, "Placa inválida (use ABC1234 ou ABC1D23)" unless valid?
      end

      def to_s
        value
      end

      def valid?
        value.match?(OLD_FORMAT) || value.match?(MERCOSUL_FORMAT)
      end
    end
  end
end
