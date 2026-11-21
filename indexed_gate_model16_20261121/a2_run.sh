#!/bin/bash
set -eo pipefail
source /home/tangbiao/.local/Ascend/cann-9.3.0/set_env.sh >/dev/null 2>&1
source /home/tangbiao/.venvs/glm-ascend-py310/bin/activate
export ASCEND_RT_VISIBLE_DEVICES=7 OMP_NUM_THREADS=8 MKL_NUM_THREADS=8 OPENBLAS_NUM_THREADS=8
mkdir -p /home/tangbiao/indexed_gate_pr_20261121
cd /home/tangbiao/indexed_gate_pr_20261121
tar -xf ../indexed_gate_pr_20261121.tar
export PYTHONPATH=$PWD TRITON_CACHE_DIR=$PWD/.triton_cache
npu-smi info -t proc-mem -i 7 > before.txt
python -m pytest tests/functions/test_indexed_gate_rms_norm_scale_shift.py --mojo-target npu.a2 --mojo-implementation triton -q --junitxml=accuracy.xml > accuracy.log 2>&1
echo $? > accuracy_exit.txt
npu-smi info -t proc-mem -i 7 > after_accuracy.txt
python -m pytest tests/performance/functions/test_indexed_gate_rms_norm_scale_shift.py --mojo-target npu.a2 --mojo-implementation triton --perf-timers profiler --perf-warmup 10 --perf-repeats 10 --perf-output perf.json -q > perf.log 2>&1
echo $? > perf_exit.txt
npu-smi info -t proc-mem -i 7 > after_perf.txt
