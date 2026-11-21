#!/bin/bash
set -eo pipefail
source /usr/local/Ascend/ascend-toolkit/set_env.sh >/dev/null 2>&1
source /home/t00985010/venvs/npu210/bin/activate
export ASCEND_RT_VISIBLE_DEVICES=6 OMP_NUM_THREADS=8 MKL_NUM_THREADS=8 OPENBLAS_NUM_THREADS=8
mkdir -p /home/t00985010/indexed_gate_pr_20261121
cd /home/t00985010/indexed_gate_pr_20261121
tar -xf ../indexed_gate_pr_20261121.tar
export PYTHONPATH=$PWD TRITON_CACHE_DIR=$PWD/.triton_cache
npu-smi info -t proc-mem -i 6 > before.txt
python -m pytest tests/functions/test_indexed_gate_rms_norm_scale_shift.py --mojo-target npu.a5 --mojo-implementation triton -q --junitxml=accuracy.xml > accuracy.log 2>&1
echo $? > accuracy_exit.txt
npu-smi info -t proc-mem -i 6 > after_accuracy.txt
python -m pytest tests/performance/functions/test_indexed_gate_rms_norm_scale_shift.py --mojo-target npu.a5 --mojo-implementation triton --perf-timers profiler --perf-warmup 10 --perf-repeats 10 --perf-output perf.json -q > perf.log 2>&1
echo $? > perf_exit.txt
npu-smi info -t proc-mem -i 6 > after_perf.txt
