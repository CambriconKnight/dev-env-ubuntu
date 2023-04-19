# Runtime API usage example

Table Of Contents
- [内容描述](#description)
- [工作原理](#how-does-this-sample-work)
- [运行准备](#preparing-sample-data)
- [编译运行](#compiling-and-running-the-sample)
  * [命令行参数](#sample-options)
  * [运行示例](#bash-command-example)
- [指标说明](#print-message-and-indicator-description)

## 内容描述

本示例为MagicMind多卡多线程离线模型性能测试工具，用户可以通过传入离线模型，以及命令行参数，运行推理统计之后给出网络的性能分析。

## 工作原理

本示例以一个MagicMind离线文件作为输入，程序按如下步骤执行：
- 初始化MagicMind运行时，反序列化用户模型并逐卡构造线程池。
- 根据用户参数进行Profiler/Dump工具等环境配置，逐线程构造线程内执行流水。
- 执行流水以拷贝-执行-拷贝的方式多并发（并发度可配置）下发任务并存储执行数据。
- 生成执行数据报告。

## 运行准备

运行本示例前，用户需自行生成对应的MagicMind推理离线模型，可以使用mm_build来完成此项工作，见`samples/mm_build/README.md`。

## 编译运行

本示例提供了命令行编译和脚本编译功能，具体而言，可使用通过命令行输入：
```bash
bash samples/build_template.sh samples/mm_run
```
或
```bash
mkdir build
cd build
cmake ..
make
```
build目录下生成如下可执行文件：
```bash
mm_run
```
若需要进行交叉编译，使用命令行：
```bash
bash samples/build_template.sh samples/mm_run edge
```

### 命令行参数

```bash
./mm_run --help
```
显示命令行语法与具体备选输入。

| 参数名称 | 是否必需 | 输入格式 | 参数描述 | 注意事项 |
|---|---|---|---|---|
| magicmind_model     | 是 | --magicmind_model path              | 离线文件路径          | 指定本次执行的离线文件路径。 |
| input_dims          | 否 | --input_dims d1,d2,d3 d4,d5,d6      | 推理输入形状          | 指定本次执行的推理输入形状，默认使用离线文件中的形状，可变模型必填。 |
| batch_size          | 否 | --batch_size b1 b2 b3               | 推理输入最高维形状    | 指定本次执行的推理输入最高维度形状，覆盖input_dims。 |
| run_config          | 否 | --run_config path                   | 推理输入形状配置文件  | 指定本次执行的推理输入可变形状配置，优先级高于input_dims与batch_size，可参照example/shape_json1.json与example/shape_json2.json。[^1] |
| input_files         | 否 | --input_files path1 path2 path3     | 推理输入数据          | 指定本次执行的输入文件地址，文件格式为Binary，仅支持单组数据，暂不支持可变。 |
| output_path         | 否 | --output_path path                  | 推理输出路径          | 指定本次执行的输入目录路径，仅在给入输入数据时启用，保存的文件名为output[idx]，idx为输出序号。 |
| plugin              | 否 | --plugin path1 path2 path3          | Plugin算子库路径      | 指定Plugin算子库地址，可以动态链接多个库。 |
| devices             | 否 | --devices id1 id2 id3               | 执行设备号            | 默认0卡推理，支持多卡推理。  |
| threads             | 否 | --threads num                       | 执行线程数            | 指定每个设备以多少线程并发进行推理。 |
| bind_cluster        | 否 | --bind_cluster 0/1/True/False       | Cluster绑定           | 指定每个CPU对应的线程绑定到1个cluster上。[^2] |
| warmup              | 否 | --warmup time                       | 预热时长              | 指定单个线程推理时预热时长，单位毫秒，默认200ms。 |
| duration            | 否 | --duration time                     | 执行时长              | 指定单个线程推理执行时间，单位毫秒，默认3000ms。[^3] |
| iterations          | 否 | --iterations num                    | 执行推理次数          | 指定单个线程推理执行次数。 |
| disable_data_copy   | 否 | --disable_data_copy 0/1/True/False  | 关闭拷贝              | 指定执行时是否跳过拷贝阶段，用于验证PCIE是否为网络推理瓶颈。如果跳过拷贝阶段，将不再host内存申请，推理输入数据也将无效，但会保留device内存申请，届时流水结构参数对性能的影响会不显著。 |
| host_async          | 否 | --host_async 0/1/True/False         | 使用异步线程          | 指定使用MLU队列异步执行还是使用host线程异步执行，流水模型见本文档描述。 |
| buffer_depth        | 否 | --buffer_depth num                  | 拷入地址深度          | 指定拷入内存的并发深度，每层深度会增加一份输入内存占用。流水模型见本文档描述。 |
| infer_depth         | 否 | --infer_depth num                   | 推理深度              | 指定执行队列的并发深度，每层深度会增加一份执行/输出内存占用。流水模型见本文档描述。 |
| kernel_capture      | 否 | --kernel_capture 0/1/True/False     | 开启KernelCapture功能 | 指定是否使能运行时的KernelCapture功能。[^4] |
| trace_path          | 否 | --trace_path path                   | 性能数据路径          | 指定将推理的整体性能统计数据保存在指定路径下，格式为json。 |
| debug_path          | 否 | --debug_path path                   | 调试数据路径          | 指定将推理的逐层精度数据保存在指定路径下，仅在给入输入数据时启用。默认为不保存。对性能会产生较大影响。 |
| perf_path           | 否 | --perf_path path                    | 性能采集路径          | 指定将推理的详细性能数据采集并保存在指定路径下，默认为不采集, 对性能会产生较大影响。[^5] |
| trace_pmu           | 否 | --trace_pmu 0/1/True/False          | 采集带宽占用数据      | 指定将推理过程中的带宽占用数据收集并打印，默认为不采集，必须独占采集。 |
| trace_time          | 否 | --trace_time none/dev/host/both     | 如何采集时钟数据      | 指定用何种方式推理过程中各个阶段的时钟数据输出，默认为使用host时钟，对性能会产生些微影响。[^6] |

[^1]: json配置文件格式有两种，以inputType区分。
当inputType为0时表示按顺序输入，见`example/shape_json1.json`。
当inputType为1时表示按名称输入，见`example/shape_json2.json`，与按顺序输入的区别在于根据名称将shape传给模型。
执行时以配置的形状组顺序循环推理。

[^2]: 使用此功能提升性能需要同时在编译期提供Config说明设备资源上限，具体使用方式见《寒武纪MagicMind调优指南》中`性能优化指南`-`部署侧硬件资源信息`一节。

[^3]: 每个线程中的推理会执行到iterations总耗时和duration时长的最大值为止。

[^4]: 开启后，MagicMind会捕获第一轮迭代执行的kernel，后续迭代会复用捕获的kernel，从而节约下发开销，提高推理性能。该功能适用于小负载场景，且需要满足一些约束，详情可参考《寒武纪MagicMind用户手册》。

[^5]: 逐层性能精度数据执行时间较为缓慢，且每次推理均会进行数据抓取，建议使用时将预热时长与执行时长置为0或小值，将迭代次数置为1。

[^6]: 不采集中间各个阶段的时钟(none)可以获得整体最高的throughput，mm_run会只输出各个接口的时延，而不采集异步执行的性能数据，适合评测整体性能。只采集MLU时钟数据性能(dev)为其次，采集Host时钟性能(host)为再次，全部时钟数据采集((both)对执行/拷贝时间较小的网络较为不友好，但可以分析各阶段性能数据。设置为both后，工具会分析整体数据输出性能分析建议。

## 流水说明

流水以整体流水（拷入，下发，拷出，同步）分阶段描述，整体流水基本逻辑如图：

![](example/process.png)

下发流程在Query内进行同步，直到整个流程的时长走完且迭代次数用完为止。

![](example/prepare.png)

对内部流水而言，不区分其具体执行的设备，对给定的A个输入形状，会有B个Buffer队列和C个执行队列，具体队列数量可以由用户自定义，对拷贝和执行占比不同的网络，最优的队列深度也不同。

![](example/cpin.png)

![](example/enqueue.png)

![](example/cpout.png)

拷入/执行/拷出的行动基本类似，均为查询前继动作的输出->查看当前是否有下发位置->下发并将异步信息和同步点推入队列，供下一动作使用。

![](example/sync.png)

以队列下发满载为可同步的标志，即将所有队列尽可能打满后再开始同步，保证设备的占用率尽可能的高来达到更好的整体效率。

## 打印信息及指标说明

- 用户传参打印：

```bash
==================== Parameter Information
--magicmind_model<Str>        : model2
--input_dims<Vec<Vec<Int>>>   : 1,2,3,4 _ 5,6,7
--batch_size<Vec<Int>>        :
--run_config<Str>             :
--input_files<Vec<Str>>       : test/input1,test/input1,test/input1
--output_path<Str>            : ./
--plugin<Vec<Str>>            :
--devices<Vec<Int>>           : 0
--threads<Int>                : 1
--bind_cluster<Bool>          : false
--warmup<Int>                 : 200
--duration<Int>               : 0
--iterations<Int>             : 1
--disable_data_copy<Bool>     : false
--host_async<Bool>            : false
--buffer_depth<Int>           : 2
--infer_depth<Int>            : 2
--kernel_capture<Bool>        : false
--trace_path<Str>             : ./
--debug_path<Str>             : ./
--perf_path<Str>              : ./
--trace_pmu<Bool>             : false
--trace_time<Str>             : host
MagicMind: 11534336
CNRT: 50801
CNAPI: 10803
PID: 12345
```

- 模型信息打印：

```bash
=================== Model Information
Size:     5581
Input num: 1
Input info [
input0            : [-1, -1, -1, -1], FLOAT
]
Output info [
output0           : [-1, -1, -1, -1], FLOAT
]
```

- 设备静态信息打印：

```bash
=================== Device Information
Device ID:                    0
Compute Capability:           3.0
Cluster Number:               8
MLU Core Clock Rate:          1 (GHz)
Total Memory Size:            24576 (MB)
Memory Bus Width:             384 (bits)
Memory Clock Rate:            3.2 (GHz)
Maximum Queue Size:           4080
Maximum Notifer Size:         24000
Sparse Computing Support:     0
```

- 设备运行时信息打印

独立线程每100毫秒采样一次设备信息:
```bash
=================== Host Occupancy Summary
UserMode Occupancy(%):        min: 0.66225    max: 0.7622     mean: 0.71222    median: 0.71222    percentile: (90%) 0.7622     (95%) 0.7622     (99%) 0.7622
KernelMode Occupancy(%):      min: 0.7622     max: 0.99338    mean: 0.87779    median: 0.87779    percentile: (90%) 0.99338    (95%) 0.99338    (99%) 0.99338
VirtualMem Usage(GB):         min: 0.84878    max: 0.85665    mean: 0.85271    median: 0.85271    percentile: (90%) 0.85665    (95%) 0.85665    (99%) 0.85665
ResidentSet Usage(GB):        min: 0.26544    max: 0.26585    mean: 0.26564    median: 0.26564    percentile: (90%) 0.26585    (95%) 0.26585    (99%) 0.26585
=================== Device 0 Utilization Summary
chip_util(%):                 min: 0          max: 1          mean: 0.5        median: 0.5        percentile: (90%) 1          (95%) 1          (99%) 1
mem_util(MB):                 min: 1805       max: 1805       mean: 1805       median: 1805       percentile: (90%) 1805       (95%) 1805       (99%) 1805
power_util(W):                min: 34         max: 34         mean: 34         median: 34         percentile: (90%) 34         (95%) 34         (99%) 34
temp_util(C):                 min: 33         max: 33         mean: 33         median: 33         percentile: (90%) 33         (95%) 33         (99%) 33
```
- 带宽占用率打印

独立线程每100毫秒采样一次信息，小于100毫秒的任务不会进行采样，在设置trace_pmu后打印。
```bash
=================== Device 0 PMU Summary
DRAM read(MB/s):              min: 450.86     max: 572.07     mean: 535.81     median: 532.79     percentile: (90%) 567.16     (95%) 568.57     (99%) 572.07
DRAM write(MB/s):             min: 217.38     max: 290.75     mean: 271.52     median: 271.28     percentile: (90%) 287.95     (95%) 289.03     (99%) 290.75
PCIE read(MB/s):              min: 31.293     max: 50.365     mean: 39.137     median: 37.985     percentile: (90%) 44.635     (95%) 46.441     (99%) 50.365
PCIE write(MB/s):             min: 72.272     max: 116.82     mean: 104.86     median: 104.49     percentile: (90%) 115.05     (95%) 115.79     (99%) 116.82
core read(MB/s):              min: 183.43     max: 294.77     mean: 264.99     median: 264.44     percentile: (90%) 290.24     (95%) 292.23     (99%) 294.77
core write(MB/s):             min: 27.7       max: 44.519     mean: 40.019     median: 39.937     percentile: (90%) 43.831     (95%) 44.131     (99%) 44.519
alu cycles(cycles/us):        min: 30.915     max: 49.68      mean: 44.662     median: 44.57      percentile: (90%) 48.918     (95%) 49.249     (99%) 49.68
lt cycles(cycles/us):         min: 0          max: 0          mean: 0          median: 0          percentile: (90%) 0          (95%) 0          (99%) 0
```

- Trace信息打印

```bash
2022-06-17 06:38:41.652209: INFO: samples/cc/common/timer.cc:34] DeserializeModel time is 1958.32 ms.
2022-06-17 06:38:41.653212: INFO: samples/cc/common/timer.cc:34] CreateEngine 0 time is 0.372 ms.
2022-06-17 06:38:41.653227: INFO: samples/cc/mm_run/run.cc:206] Const data size: 0(MB)
2022-06-17 06:38:41.654884: INFO: samples/cc/mm_run/run.cc:223] ContextMaxworkspace Size: 8(MB)
2022-06-17 06:38:41.655386: INFO: samples/cc/common/timer.cc:34] CreateContext time is 0.229 ms.
2022-06-17 06:38:41.655432: INFO: samples/cc/common/timer.cc:34] CreateContext time is 0.272 ms.
2022-06-17 06:38:41.860581: INFO: samples/cc/common/timer.cc:34] warmup_dev_0_thread_1 time is 201.33 ms.
2022-06-17 06:38:41.860588: INFO: samples/cc/common/timer.cc:34] warmup_dev_0_thread_0 time is 201.481 ms.
2022-06-17 06:38:44.862217: INFO: samples/cc/common/timer.cc:34] infer_dev_0_thread_0 time is 3001.55 ms.
2022-06-17 06:38:44.862282: INFO: samples/cc/common/timer.cc:34] infer_dev_0_thread_1 time is 3001.64 ms.
2022-06-17 06:38:44.862290: INFO: samples/cc/mm_run/run.cc:55] Run dev_0_thread_0 finished with total duration: 3000.39, generating report...
========= Input Buffer Info =========
Buffers Info: InputBufferGroup0
Num: 1
[0]: 
  Name: main/arg:0
  Datatype: UINT8
  Layout: NCHW
  Dim: [1, 1, 195, 195]
  Size: 38025
  Record Addr: 0x30080fff9694000
  TensorLoc: kMLU
  BufferInfo: 
    Malloc by us: 1
    Current Host Addr: 0
    Total Host Size: 0
    Host Addr depth: 0
    Current Dev Addr: 0x30080fff9694000
    Total Dev Size: 38025
    Dev Addr depth: 1
    Current Size: 38025
========= Output Buffer Info =========
Buffers Info: OutputBufferGroup0
Num: 1
[0]: 
  Name: main/mm.identityn:0
  Datatype: FLOAT
  Layout: NCHW
  Dim: [1, 256]
  Size: 1024
  Record Addr: 0x30080fff96a8000
  TensorLoc: kMLU
  BufferInfo: 
    Malloc by us: 1
    Current Host Addr: 0
    Total Host Size: 0
    Host Addr depth: 0
    Current Dev Addr: 0x30080fff96a8000
    Total Dev Size: 1024
    Dev Addr depth: 1
    Current Size: 1024
2022-06-17 06:38:44.862320: INFO: samples/cc/mm_run/run.cc:55] Run dev_0_thread_1 finished with total duration: 3000.34, generating report...
========= Input Buffer Info =========
Buffers Info: InputBufferGroup0
Num: 1
[0]: 
  Name: main/arg:0
  Datatype: UINT8
  Layout: NCHW
  Dim: [1, 1, 195, 195]
  Size: 38025
  Record Addr: 0x30080fff9694000
  TensorLoc: kMLU
  BufferInfo: 
    Malloc by us: 1
    Current Host Addr: 0
    Total Host Size: 0
    Host Addr depth: 0
    Current Dev Addr: 0x30080fff9694000
    Total Dev Size: 38025
    Dev Addr depth: 1
    Current Size: 38025
========= Output Buffer Info =========
Buffers Info: OutputBufferGroup0
Num: 1
[0]: 
  Name: main/mm.identityn:0
  Datatype: FLOAT
  Layout: NCHW
  Dim: [1, 256]
  Size: 1024
  Record Addr: 0x30080fff96a8000
  TensorLoc: kMLU
  BufferInfo: 
    Malloc by us: 1
    Current Host Addr: 0
    Total Host Size: 0
    Host Addr depth: 0
    Current Dev Addr: 0x30080fff96a8000
    Total Dev Size: 1024
    Dev Addr depth: 1
    Current Size: 1024
```
  - DeserializeModel time：反序列化模型时间。

  - CreateEngine idx time：MagicMind Runtime Engine构造时间，多卡时会产生多个Engine构造。

  - Const data size：静态数据大小，即模型权重和常量。

  - ContextMaxworkspace Size：最大Workspace大小，可变时会遍历多个输入形状查询最大的数值。

  - CreateContext time：构造MagicMind Runtime Context时长，多线程时会产生多个Context构造。

  - warmup_dev_idx_thread_idx time：第某卡某线程预热时长，使用时钟为Host时钟。

  - infer_dev_idx_thread_idx time：第某卡某线程推理时长，使用时钟为Host时钟。

  - Run dev_idx_thread_idx finished with total duration：第某卡某线程推理时长，使用时钟为Dev时钟。

  - Input/Output Buffer Info：执行后的IO内存申请状况。

    - Input/OutputBufferGroupidx：打印为第idx组输入输出内存状态，输入内存组数为buffer_depth参数数量，输出内存组数为infer_depth参数数量。

    - Num：本组包括多少个输入/输出，与网络输入输出数量一致。

    - [idx]：第idx个输入/输出信息。

    - Name：本个Buffer对应的Tensor名称。

    - Datatype：本个Buffer对应的数据类型。

    - Dim：本个Buffer最后一次执行时记录的形状信息。

    - Size：本个Buffer最后一次执行时记录的Size信息。

    - Record Addr：当前记录在Tensor里的地址。

    - TensorLoc：当前记录在Tensor里的地址设备。

    - Malloc by us：是否需要由用户侧申请，若网络形状为可变且依赖运行时数据，网络输出可能无法由用户侧申请。

    - Current Host Addr：当前记录使用的Host地址。

    - Total Host Size：在整个Buffer使用周期内，申请的总Host大小，可变时会申请较多内存以保证性能和复用性。

    - Host Addr Depth：在整个Buffer使用周期内，申请的Host内存队列长度，可变时会申请多于一组内存。

    - Current Dev Addr：当前记录使用的MLU地址。

    - Total Dev Size：在整个Buffer使用周期内，申请的总MLU大小，可变时会申请较多内存以保证性能和复用性。

    - Dev Addr Depth：在整个Buffer使用周期内，申请的MLU内存队列长度，可变时会申请多于一组内存。

    - Current Size：当前记录的使用内存大小。

- 性能信息打印，dev clock部分在开启选项trace_time为dev或both模式后打印，host clock部分在开启trace_time为host或both后打印：

```bash
=================== Performance Summary
Total iterations:             14466
Host wall time(s):            3.00164
Total MLU compute time(host clock, s): 1.26222
Total MLU compute time(dev clock, s): 0.891635
Throughput (qps):             28916.2 with total batch sizes: 86796 and 4819.36 iterations/second
Input shape group 0: [main/arg:0: [1, 3, 64, 64], main/arg:1: [9, 3, 128, 128], main/arg:2: [1, 3, 24, 24]]
  H2D Summary:
  Latency(host clock, ms):    min: 0.12       max: 1.053      mean: 0.36809    median: 0.326      percentile: (90%) 0.651      (95%) 0.716      (99%) 0.808
  Latency(dev clock, ms):     min: 0.12       max: 1.036      mean: 0.35437    median: 0.312      percentile: (90%) 0.631      (95%) 0.697      (99%) 0.785
  Interface Duration(ms):     min: 0.016      max: 0.104      mean: 0.028189   median: 0.025      percentile: (90%) 0.039      (95%) 0.045      (99%) 0.064
  MLU Compute (Launch jobs) Summary:
  Latency(host clock, ms):    min: 0.057      max: 0.237      mean: 0.08457    median: 0.08       percentile: (90%) 0.103      (95%) 0.113      (99%) 0.14
  Latency(dev clock, ms):     min: 0.051      max: 0.079      mean: 0.055361   median: 0.054      percentile: (90%) 0.06       (95%) 0.066      (99%) 0.075
  Interface Duration(ms):     min: 0.031      max: 0.194      mean: 0.050641   median: 0.043      percentile: (90%) 0.074      (95%) 0.085      (99%) 0.127
  D2H Summary:
  Latency(host clock, ms):    min: 0.162      max: 1.223      mean: 0.41258    median: 0.391      percentile: (90%) 0.635      (95%) 0.694      (99%) 0.848
  Latency(dev clock, ms):     min: 0.157      max: 1.207      mean: 0.4014     median: 0.378      percentile: (90%) 0.622      (95%) 0.683      (99%) 0.837
  Interface Duration(ms):     min: 0.017      max: 0.11       mean: 0.027554   median: 0.025      percentile: (90%) 0.037      (95%) 0.043      (99%) 0.063
  Total Latency Summary(H2D + Compute + D2H):
  Latency(host clock, ms):    min: 0.372      max: 1.884      mean: 0.86524    median: 0.846      percentile: (90%) 1.204      (95%) 1.309      (99%) 1.44
  Latency(dev clock, ms):     min: 0.349      max: 1.805      mean: 0.81113    median: 0.788      percentile: (90%) 1.145      (95%) 1.251      (99%) 1.377
Input shape group 1: [main/arg:0: [3, 3, 256, 256], main/arg:1: [], main/arg:2: [1, 3, 24, 24]]
  H2D Summary:
  Latency(host clock, ms):    min: 0.17       max: 0.986      mean: 0.36364    median: 0.335      percentile: (90%) 0.581      (95%) 0.65       (99%) 0.751
  Latency(dev clock, ms):     min: 0.17       max: 0.956      mean: 0.35221    median: 0.325      percentile: (90%) 0.569      (95%) 0.633      (99%) 0.74
  Interface Duration(ms):     min: 0.016      max: 0.137      mean: 0.027703   median: 0.025      percentile: (90%) 0.039      (95%) 0.044      (99%) 0.069
  MLU Compute (Launch jobs) Summary:
  Latency(host clock, ms):    min: 0.069      max: 0.218      mean: 0.089937   median: 0.087      percentile: (90%) 0.105      (95%) 0.112      (99%) 0.141
  Latency(dev clock, ms):     min: 0.061      max: 0.097      mean: 0.067912   median: 0.066      percentile: (90%) 0.075      (95%) 0.084      (99%) 0.092
  Interface Duration(ms):     min: 0.03       max: 0.189      mean: 0.049864   median: 0.043      percentile: (90%) 0.073      (95%) 0.085      (99%) 0.129
  D2H Summary:
  Latency(host clock, ms):    min: 0.198      max: 1.078      mean: 0.36656    median: 0.349      percentile: (90%) 0.531      (95%) 0.619      (99%) 0.731
  Latency(dev clock, ms):     min: 0.192      max: 1.07       mean: 0.35664    median: 0.339      percentile: (90%) 0.52       (95%) 0.608      (99%) 0.722
  Interface Duration(ms):     min: 0.016      max: 0.204      mean: 0.02675    median: 0.024      percentile: (90%) 0.036      (95%) 0.042      (99%) 0.065
  Total Latency Summary(H2D + Compute + D2H):
  Latency(host clock, ms):    min: 0.463      max: 1.779      mean: 0.82014    median: 0.788      percentile: (90%) 1.082      (95%) 1.168      (99%) 1.342
  Latency(dev clock, ms):     min: 0.45       max: 1.71       mean: 0.77676    median: 0.745      percentile: (90%) 1.037      (95%) 1.121      (99%) 1.287
Trace average MLU Compute perf over 1446 runs (723 per thread):
  Latency(host clock, ms): 0.089163    Latency(dev clock, ms): 0.061947    Interface Duration(ms): 0.052804
  Latency(host clock, ms): 0.082515    Latency(dev clock, ms): 0.061278    Interface Duration(ms): 0.042131
  Latency(host clock, ms): 0.085427    Latency(dev clock, ms): 0.061362    Interface Duration(ms): 0.046763
  Latency(host clock, ms): 0.093616    Latency(dev clock, ms): 0.062042    Interface Duration(ms): 0.061057
  Latency(host clock, ms): 0.085943    Latency(dev clock, ms): 0.062161    Interface Duration(ms): 0.047358
  Latency(host clock, ms): 0.084061    Latency(dev clock, ms): 0.062252    Interface Duration(ms): 0.043368
  Latency(host clock, ms): 0.085081    Latency(dev clock, ms): 0.061808    Interface Duration(ms): 0.044748
  Latency(host clock, ms): 0.086985    Latency(dev clock, ms): 0.061703    Interface Duration(ms): 0.049239
  Latency(host clock, ms): 0.088176    Latency(dev clock, ms): 0.060624    Interface Duration(ms): 0.055354
```

- 术语表：

  - 总结部分

    - Total iterations：总推理迭代数。

    - Host wall time(s)：Host最长时延，即最快线程起始，至最慢线程截止总时长。

    - Total MLU compute time(host clock, s)：MLU总计算时长，使用时钟为Host时钟。如果明显短于walltime，说明MLU未得到充分利用。原因可能是主机端的开销太大或者h2d/d2h数据传输开销太大。

    - Total MLU compute time(dev clock, s)：MLU总计算时长，使用时钟为Dev时钟，如果明显短于host clock与walltime，说明运行时开销较大，空泡较多。

    - Throughput (qps)：每秒推理张数，由`Iterations*batchsize/walltime`得到，对于多输入网络，张数使用所有输入中最高维最大数。如果`Throughput << 1/MLU Compute Time`，说明MLU未得到充分利用。原因可能是主机端的开销太大或者h2d/d2h数据传输开销太大。同时提供了使用的总张数数量和每秒推理迭代数。

    - Input shape group idx：第某组输入形状，下述推理时间总结为对每一形状输入总结其执行时间。

  - 单阶段性能部分：每一阶段均计算三个时钟，分别为Host接口开销，队列下发在驱动Host（或异步线程Host）的时钟计时，队列下发在设备队列的时钟计时（若为异步线程则使用Host计时）。

    - H2D Summary：拷入时间总结。

    - MLU Compute (Launch jobs) Summary：MLU计算下发时间总结。

    - D2H Summary：拷出时间总结。

    - Total Latency Summary(H2D + Compute + D2H)：总时长（拷入+拷出+下发）时间总结。

    - Latency(host clock, ms)：驱动Host或异步线程Host为某操作实际执行前后所计时时长。

    - Latency(dev clock, ms)：驱动队列（MLU侧）为某操作实际执行前后所计时时长，该时长与同操作Host时长的差异为软硬件通信开销。

    - Interface Duration(ms)：拷贝或下发的接口时长，该时长若与Latency相比较长，说明此操作在Host的软件开销较大。

  - 统计部分

    - min/max/mean/mediam：某项数据统计意义上的最小值，最大值，平均值，中位数。

    - percentile：某项数据的*百分位数*，即该项数据在所有统计中从小到大排序后的累计百分位所对应的数值。

  - 采样部分

    - Trace average MLU Compute perf over X runs：若干组线程在每若干次执行统计一次MLU计算下发时间平均数据。可以用于计算性能预热及执行曲线。
