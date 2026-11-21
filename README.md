# PR535 balanced14 evidence (2026-11-21)

Tested code: 9351ce90ead79dad03b1ecd0bc0dff5b1f98f3ca.
A2/A5 repository accuracy/boundary/graph: 128/128 each; repository performance: 14/14 each.
Frozen input specification SHA256: 58ae996e202c258125c8ccafddc6399b45701893f2503805ec2449e6687a5218.

`a2_balanced14.csv` and `a5_balanced14.csv`: one row per case; complete samples, pipeline times and kernel names in parsed.json/native CSVs. All windows retained, including the noisy A2 gb08 recheck. Kernel coverage is 100% of collected target launches (one target kernel per call); not whole-model coverage.

Reproduction: extract reproduction/ to a clean remote directory. Source the matching CANN environment and activate Torch 2.7.1. Run `python worker.py a2 0` or `python worker.py a5 2` (replace card IDs with an idle healthy card). This runs the repository tests before paired DUT captures. Then run `python followup.py <arch> <card>` for the repository performance entry and payload fingerprints. After it completes, run `python calibration_followup.py <arch> <card>` for device-kernel copy calibration and A2 gb08 rechecks. The `.agents` runner snapshot includes the explicitly retained cold-cache extension and exact-single-kernel sample normalization; this is not an upstream runner change. Device samples are independently counted from raw CSVs: 40 per window.

Profiler target duration excludes the flush kernel, host wrapper time and allocation; complete public API is actually invoked. Warmup=100/repeats=40 for DUT. `GLM_CLEAR_L2=0` means fixed input without flush; `1` performs the runtime 192 MiB sum+synchronize before every call. Standard repository profiler uses its own cache policy; those timings are separate from acceptance.

Copy: int32 read+write, BLOCK8192, sizes32/64/128M elements. Device calibration uses40samples/window,2windows,size medians,max bandwidth. Event-copy pre/post measurements retained only as a separately labeled historical-reference method. Semantic byte model=8*T*K+4*T+4*R*M, aggregate uses summed bytes/summed case mean duration. A2 Event-reference MBU56.94%; device-aligned33.89%. A5 hot L20 speedup0.9225x, cold device-alignedMBU61.93%. Targets unmet. Copy reference is not theoretical HBM peak; working-set sensitivity prevents a hardware-saturation claim.

L20 values are user-provided20-sample hot-profiler means from the frozen balanced14 package, not rerun or raw-trace-verified locally. Source input fingerprints are independently checked. The current comparison is not a same-day controlled cross-device rerun.

Machine/account names and absolute user paths in reports/logs were redacted. File manifest records both original and published hashes. Native numeric timing/PMU values were not edited. Full raw profiler directories are retained locally and on device; this archive publishes the compact native kernel_details.csv evidence plus logs/configuration/tests.
