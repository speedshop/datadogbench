require 'benchmark/ips'
require 'active_support/all'


as_enabled = ENV['AS_ENABLED'] == 'true'
dd_enabled = ENV['DD_ENABLED'] == 'true'
dd_enabled = true if as_enabled

if ENV['PATCH']
  module Datadog
    module Tracing
      module Contrib
        module ActiveSupport
          module Cache
            module Events
              module OverrideAll
                def all
                  []
                end
              end

              class << self
                prepend OverrideAll
              end
            end
          end
        end
      end
    end
  end
end

if dd_enabled
  require 'datadog'

  # Configure Datadog in development mode
  Datadog.configure do |c|
    c.tracing.instrument :active_support, enabled: as_enabled
  end
end

# Create a memory store cache
cache = ActiveSupport::Cache::MemoryStore.new

# Set a test value in the cache
TEST_KEY = "test_key"
cache.write(TEST_KEY, "test_value")

# Run the benchmark
Benchmark.ips do |x|
  x.report("cache.read") do
    cache.read(TEST_KEY)
  end

  x.compare!
end

if ENV['FLAMEGRAPH']
  require 'singed'
  Singed.output_directory = "/tmp"
  flamegraph(interval: 100) {
    10_000.times do
      cache.read(TEST_KEY)
    end
  }
end
