require 'benchmark/ips'
require 'active_support/all'
require 'datadog'

# Configure Datadog in development mode
Datadog.configure do |c|
  c.tracing.instrument :active_support, enabled: true
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
