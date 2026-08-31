# frozen_string_literal: true

module Domain
  class Error < StandardError; end
  class InvalidTransition < Error; end
  class InsufficientStock < Error; end
  class InvalidDocument < Error; end
  class InvalidPlate < Error; end
  class BudgetNotReady < Error; end
end
