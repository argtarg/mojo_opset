# Request-index conversion performance evidence

Source commit: 0217c4274d8ed0a14ac09ee691e4d9633fc7b9fe

The correctness suites include the block-size and backend width guards. The Triton kernel code is unchanged.

The per-input SHA-256 fingerprints match the previous PR revision for all seven workloads.

Seven named workloads use the shared recipe in the PR's tests and the named shapes below.
Target device kernel timing uses the public API, forty DUT samples per window and a 100-call warmup.
All measured DUT windows are retained in the native manifest. Cold captures use a 192 MiB eviction buffer before each call.
Eviction order and target row counts were verified in every native CSV.
The repository-provided profiler suite is a separate execution check using its own cache policy.

A2: Ascend910B3; cold DUT device durations normalized to a same-card Event-timed cold int32 copy.
A5: Ascend950PR; cold DUT and cold copy both use device durations.
The hot L20 reference means came from the provided benchmark data and were not rerun on this date.
The manifest covers each device-native CSV in this archive. Paths identify workload names and
windows. User accounts and network addresses are omitted.
