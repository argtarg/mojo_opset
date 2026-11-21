# Indexed gated RMSNorm: model16 evidence

This branch contains measurement evidence for the operator PR; it is not part of the PR's code diff.

The 16 performance cases are derived from MiniMax H3 layout rules at vllm-omni revision `d613fdb62c432a342681e88b307d36b54f6ed5f0`. Values are seeded synthetic tensors, not checkpoint outputs or an inference trace. Each case preserves global condition counts, local clustered indices, and shared AdaLN parent storage with row stride `6 * 5376`.

Validated implementation sources:

| Platform | Source SHA256 | Integrated source SHA256 |
| --- | --- | --- |
| A2 | `bfbf04aef961984bc0050be36e9bd0e58fdef703a2bbbd276c76eaa811434c20` | `2ae1989981e28e012e54f8070cb1abb181051c630a4d7550931c3845fc64e389` |
| A5 | `cb970f0caf9ca43f2e49e2e10ab09461e7385d13c1018cfe13b77ce7e47df051` | `eaaa05abf893253b0b9cf820b79798112357d6343cc4ee8045047c6407e5f17d` |

`source_audit.json` verifies identical JIT/plan and launch ASTs. Integration replaces the standalone module wrapper with the repository public API and custom-op/fake registration; core queries use the input device.

On 2026-11-21, both A2 and A5 passed 151/151 repository functional tests and 16/16 performance-entry tests. XML reports and full performance JSON retain sample counts, kernel names, memory and cache settings. The current repository's fixed-input profiler flushes L2, uses one input and reports device span. These entry checks do not replace the two-input, device-Duration-sum acceptance measurements below.

| Acceptance dataset | Result | Interpretation |
| --- | --- | --- |
| A2 cold-L2 aggregate semantic MBU | 69.81716% | Above the requested 60%; per-case arithmetic mean 65.62824%; 512-row case 46.066% |
| A5 no-explicit-flush L20/A5 geometric mean | 1.70490231x | Below 1.85x; reference comparison only |
| A5 cold-L2 aggregate semantic MBU | 90.94056% | Close to this measured copy reference, particularly larger cases; not a universal hardware limit |

A2 no-PMU timings were collected on 2026-11-19; independent PipeUtilization samples on 2026-11-21. A5 parent/candidate no-PMU and independent PMU data were collected on 2026-11-21. Preserve this separation: PMU times must not replace acceptance timings. Pipeline activities overlap and are not exclusive critical-path shares. Per-kernel times, AIV weights and sample coverage are retained in the archives and summary JSON.

The L20 data came from the user's seven-file autotuned run. Concurrency was not verified; L20 used one input while A5 used two, and preconditioning/eviction differed. The ratio is provided transparently, without claiming matched-protocol acceptance. Historical 13-case Event/Graph results are excluded from this new 16-case device-time comparison.

See the reports and compact one-case-per-row CSVs for methods and individual results. The ZIP archives preserve raw `kernel_details.csv`, input/source bindings, controls and measurement scripts. `manifest.json` records artifact sizes and SHA256 hashes. Large `.pt` caches are excluded.
