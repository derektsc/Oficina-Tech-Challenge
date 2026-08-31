# frozen_string_literal: true

module Domain
  module Customers
    class Document
      attr_reader :digits, :type

      def initialize(raw)
        @digits = raw.to_s.gsub(/\D/, "")
        @type = infer_type
        raise Domain::InvalidDocument, "CPF/CNPJ inválido" unless valid?
      end

      def to_s
        digits
      end

      def valid?
        return false if digits.chars.uniq.size == 1

        type == :cpf ? valid_cpf? : valid_cnpj?
      end

      def as_json(*)
        { document: digits, document_type: type.to_s }
      end

      private

      def infer_type
        case digits.length
        when 11 then :cpf
        when 14 then :cnpj
        else
          raise Domain::InvalidDocument, "Informe um CPF (11 dígitos) ou CNPJ (14 dígitos)"
        end
      end

      def valid_cpf?
        check = (0..1).map do |i|
          sum = digits[0, 9 + i].chars.each_with_index.sum { |n, idx| n.to_i * ((9 + i + 1) - idx) }
          rest = (sum * 10) % 11
          rest = 0 if rest == 10
          rest
        end
        check == [digits[9].to_i, digits[10].to_i]
      end

      def valid_cnpj?
        weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        d1 = check_digit(digits[0, 12], weights1)
        d2 = check_digit(digits[0, 13], weights2)
        d1 == digits[12].to_i && d2 == digits[13].to_i
      end

      def check_digit(partial, weights)
        sum = partial.chars.each_with_index.sum { |n, i| n.to_i * weights[i] }
        rest = sum % 11
        rest < 2 ? 0 : 11 - rest
      end
    end
  end
end
