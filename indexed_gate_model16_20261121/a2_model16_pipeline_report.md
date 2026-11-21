# A2 新16例：清L2板端bound

采集日期：2026-11-21（Asia/Shanghai）。原A2最优版源码不变，物理卡7、逻辑0。原有16/16精度通过及输入冻结哈希已核对。

使用triton-npu-run-eval的profile-bench逐case调用torch_npu.profiler，PipeUtilization/Level1；每次调用前用1GiB缓冲区读写驱逐并同步。每例10次正式调用，两个输入交替；160次调用均已核验驱逐配对。三次表连续化仍在public forward内部，未移出采集。

按对应pipe_time/aiv_time验证_ratio单位后，使用100*sum(pipe_time)/sum(aiv_time)汇总。下面是融合kernel的活动率百分数，可重叠，不表示互斥时间份额、MBU或已证明的关键路径。完整device与表搬运的活动率单独保留在CSV。

本轮PMU时长仅作诊断；11月19日独立no-PMU清L2时间与69.82%总量MBU不被替换。观察到其他同卡进程的尝试保留且不采用；选取每例首个可用尝试。

| Case | Rows | C/活跃 | Vector% | MTE2% | MTE3% | Scalar% |
|---|---:|---:|---:|---:|---:|---:|
| model_t2va_smoke_step0_u1 | 4096 | 3/3 | 61.60 | 52.37 | 14.29 | 8.33 |
| model_t2va_smoke_mid_u1 | 4096 | 6/3 | 60.79 | 52.44 | 14.43 | 8.22 |
| model_t2va_smoke_mid_u8_rank0 | 512 | 6/3 | 54.94 | 49.37 | 13.57 | 13.24 |
| model_t2va_doc209_u1 | 16448 | 6/3 | 68.71 | 46.83 | 14.20 | 8.56 |
| model_t2va_doc209_u4_rank0 | 4112 | 6/3 | 60.58 | 52.44 | 14.64 | 8.23 |
| model_t2va_doc209_u4_rank3 | 4112 | 6/1 | 61.69 | 51.71 | 13.92 | 8.39 |
| model_t2va_recipe209_u1 | 63360 | 6/3 | 69.97 | 45.41 | 14.32 | 8.51 |
| model_t2va_recipe209_u4_rank0 | 15840 | 6/3 | 68.76 | 46.60 | 13.67 | 8.55 |
| model_fl2va_first_step0_u4 | 15056 | 6/4 | 68.51 | 46.83 | 13.88 | 8.54 |
| model_fl2va_first_mid_u4 | 15056 | 9/4 | 67.16 | 48.73 | 15.12 | 8.38 |
| model_fl2va_firstlast124_u4 | 10192 | 9/4 | 65.48 | 49.80 | 14.93 | 8.30 |
| model_t2va_default_limit_u4_rank3 | 27312 | 6/1 | 69.85 | 45.53 | 13.47 | 8.59 |
| model_ref2va_img_audio_step0_u1 | 10688 | 9/5 | 65.53 | 49.82 | 15.06 | 8.30 |
| model_ref2va_img_audio_mid_u1 | 10688 | 12/5 | 66.03 | 49.81 | 15.28 | 8.37 |
| model_batch2_same_step_u4_rank0 | 5136 | 6/3 | 60.97 | 52.35 | 14.73 | 8.06 |
| model_batch2_mixed_step_u4_rank3 | 5136 | 9/1 | 60.83 | 52.70 | 15.00 | 8.06 |

输入按固定模型源码重建，非模型checkpoint实跑trace；H=5376、eps=1e-5、条件表stride=(32256,1)，详情见model_cases.json。

源码SHA256：`bfbf04aef961984bc0050be36e9bd0e58fdef703a2bbbd276c76eaa811434c20`。全部保留及未采用尝试的原始kernel_details.csv、profile日志、统计CSV及快照随包归档；完整profiler目录留在远端。
