# frozen_string_literal: true

require "simplecov"
SimpleCov.start "rails" do
  skip "/spec/"
  skip "/config/"
  skip "/db/"
  minimum_coverage 80
  group "Domain", "app/lib/domain"
  group "UseCases", "app/lib/use_cases"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.order = :random
  Kernel.srand config.seed
end
