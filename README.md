# How much overhead does Datadog add to a MemoryStore access?

This much:

`enabled: false`
```
ruby 3.4.3 (2025-04-14 revision d0b7e5b6a0) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          cache.read    21.495k i/100ms
Calculating -------------------------------------
          cache.read    215.980k (± 0.4%) i/s    (4.63 μs/i) -      1.096M in   5.075759s
```

`enabled: true`
```
ruby 3.4.3 (2025-04-14 revision d0b7e5b6a0) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          cache.read     1.960k i/100ms
Calculating -------------------------------------
          cache.read     19.579k (± 5.5%) i/s   (51.08 μs/i) -     98.000k in   5.021247s
```

It adds **45 microseconds** to every cache access on my Mac, a factor of `10x`. For MemoryStore, this is generally inappropriate as you may genuinely access a MemoryStore 1k+ times in a request and expect to do that "for free".

## Usage

Uses Docker to get a DD agent.

```
bundle exec foreman start
# ... wait for the datadog agent to come up ..
bundle exec ruby ddbench.rb
```
