# A2 最优版：新增模型规则16例精度与清L2性能

测量日期：2026-11-19。A2 Ascend910B3，同机 179.184.3.2；精度卡3、性能卡7（逻辑0）。卡3出现其他任务后，在任何正式性能采样前转至空闲卡7；两张卡的环境分开保存。

**精度16/16通过；使用原已验收A2最优版，无需修改代码。** 原13例保留，不被新组替换。

输入与 index-A5 新组逐字节一致：固定模型commit d613fdb62c432a342681e88b307d36b54f6ed5f0，H=5376、eps=1e-5；conditions、SP分片及索引由模型规则推导，条件表共享父张量，stride=(32256,1)，gate/shift/scale偏移=2H/3H/4H。激活值为确定性合成数据，没有checkpoint或实际推理trace。

性能：每次public forward前执行1GiB读写驱逐并同步。每例3轮×10次、两个输入交替，融合kernel与3次表连续化kernel均取原始device Duration；驱逐不计时。完整device时间为四个工作kernel时长之和，device span另列CSV。三轮取中位数；记录全部轮次和尝试，使用首个稳定尝试，不选最快。

每轮前后插入同卡大buffer copy控制，要求与本轮独立参考差≤3%；DUT轮间变化≤max(3%,0.15μs)，完整device合计≤max(3%,2μs)。观测到其他进程时等待，不停止其他任务。所有保留窗口结束时无其他进程，控制量检查通过。

标准run-bench harness亦执行逐次驱逐，仅作harness验证；首次15例导出成功，一例profiler文件导出失败，已通过profile-bench定点复核。其含驱逐的聚合时间不作为下表性能结果。下表全部16例均来自完整有效的主测CSV。

| case | Rows | C/活跃 | 融合kernel μs | 表搬运 μs | 完整device μs |
|---|---:|---:|---:|---:|---:|
| model_t2va_smoke_step0_u1 | 4096 | 3/3 | 235.114 | 4.230 | 239.445 |
| model_t2va_smoke_mid_u1 | 4096 | 6/3 | 234.265 | 5.260 | 239.665 |
| model_t2va_smoke_mid_u8_rank0 | 512 | 6/3 | 35.231 | 5.210 | 40.521 |
| model_t2va_doc209_u1 | 16448 | 6/3 | 835.717 | 5.240 | 841.027 |
| model_t2va_doc209_u4_rank0 | 4112 | 6/3 | 235.315 | 5.220 | 240.445 |
| model_t2va_doc209_u4_rank3 | 4112 | 6/1 | 234.875 | 5.231 | 240.204 |
| model_t2va_recipe209_u1 | 63360 | 6/3 | 3121.903 | 5.180 | 3127.242 |
| model_t2va_recipe209_u4_rank0 | 15840 | 6/3 | 802.606 | 5.231 | 807.796 |
| model_fl2va_first_step0_u4 | 15056 | 6/4 | 795.236 | 5.210 | 800.476 |
| model_fl2va_first_mid_u4 | 15056 | 9/4 | 780.295 | 6.151 | 786.706 |
| model_fl2va_firstlast124_u4 | 10192 | 9/4 | 539.320 | 6.240 | 545.581 |
| model_t2va_default_limit_u4_rank3 | 27312 | 6/1 | 1373.258 | 5.300 | 1378.457 |
| model_ref2va_img_audio_step0_u1 | 10688 | 9/5 | 555.171 | 6.190 | 561.321 |
| model_ref2va_img_audio_mid_u1 | 10688 | 12/5 | 557.741 | 5.730 | 563.481 |
| model_batch2_same_step_u4_rank0 | 5136 | 6/3 | 292.706 | 5.170 | 298.166 |
| model_batch2_mixed_step_u4_rank3 | 5136 | 9/1 | 293.576 | 6.270 | 299.906 |

各列独立采用三轮中位数，因此展示的融合与表搬运之和可能与完整调用中位数有微小差异。单次调用的原始相加关系及驱逐配对已逐行核验（480次DUT、96次控制量）。

源码SHA256：`bfbf04aef961984bc0050be36e9bd0e58fdef703a2bbbd276c76eaa811434c20`。精度详细事件与原始log、环境、布局、输入冻结哈希、全部保留/排除尝试的kernel_details.csv均随包归档。完整profiler目录及临时测试payload仍在远端，交付包不含大体积pt缓存。

## 清 L2 MBU 补充

复用本次同卡原始采集及96次前后copy控制量，语义字节以实际活跃条件行数计，完整调用含三次表连续化耗时。总量 MBU 为 69.81716%，逐例算术平均 65.62824%；参考带宽 1185.64508 GB/s。详见 [MBU 报告](mbu_cold/report.md) 和 [逐例 CSV](mbu_cold/mbu_cases.csv)。

## 2026-11-21 bound 补齐

新增16例A2清L2 PipeUtilization已全部补齐，每例10次正式调用、160次驱逐配对核验通过；算子源码不变。详见[完整bound报告](../a2_model16_bound_20261121/report.md)与[关联既有无PMU时间和MBU的CSV](../a2_model16_bound_20261121/a2_model16_mbu_with_bound.csv)。本轮PMU耗时为诊断数据，不替换先前MBU计时。
