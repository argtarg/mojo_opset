# Request-index conversion performance evidence

Source commit: 4f539f676d70f776ab650c0927026183e7bf59e7

Seven named workloads use the shared recipe in the PR's tests and the named shapes below.
Target device kernel timing uses the public API, two windows of forty DUT samples per case
and a 100-call warmup. Cold captures use a 192 MiB eviction buffer before each call.
Eviction order and target row counts were verified in every native CSV.
The repository-provided profiler suite is a separate execution check using its own cache policy.

A2: Ascend910B3; cold DUT device durations normalized to a same-card Event-timed cold int32 copy.
A5: Ascend950PR; cold DUT and cold copy both use device durations.
The hot L20 reference means came from the provided benchmark data and were not rerun on this date.
The manifest covers each device-native CSV in this archive. Paths identify workload names and
windows. User accounts and network addresses are omitted.
