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

If we patch a method in `datadog` to never install any activesupport listeners, we can get another 2-3 microseconds:

```
ruby 3.4.3 (2025-04-14 revision d0b7e5b6a0) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          cache.read    55.831k i/100ms
Calculating -------------------------------------
          cache.read    551.778k (± 3.2%) i/s    (1.81 μs/i) -      2.792M in   5.065029s
```

## Credit

Initial discovery by [rianmcguire](https://github.com/rianmcguire)

## Usage

Uses Docker to get a DD agent.

```
bundle exec foreman start
# ... wait for the datadog agent to come up ..
bundle exec ruby ddbench.rb
```

## Flamegraphs

Before
![Screenshot 2025-05-14 at 12 55 04](https://github.com/user-attachments/assets/b685a215-1202-4e35-8b57-4793bff5aeb2)

After
![Screenshot 2025-05-14 at 12 54 04](https://github.com/user-attachments/assets/f3bb0fbf-4476-4cd0-9af1-65ec990d1bcb)
