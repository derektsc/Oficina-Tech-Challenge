# frozen_string_literal: true

class CPFGenerator
  def self.next
    @seq = (@seq || 0) + 1
    base = format("%09d", @seq)
    d1 = digit(base, 10)
    d2 = digit(base + d1.to_s, 11)
    "#{base}#{d1}#{d2}"
  end

  def self.digit(partial, start)
    sum = partial.chars.each_with_index.sum { |n, i| n.to_i * (start - i) }
    rest = (sum * 10) % 11
    rest == 10 ? 0 : rest
  end
  private_class_method :digit
end
