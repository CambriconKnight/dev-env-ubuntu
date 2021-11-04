<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu">
        <h1 align="center"> 如何为 【dev-env-ubuntu】 做贡献 </h1>
    </a>
</p>

<!-- TOC -->

- [1.准备工作](#1准备工作)
  - [1.1.了解贡献协议与流程](#11了解贡献协议与流程)
- [2.代码提交](#2代码提交)
  - [2.1.CodeStyle](#21codestyle)
  - [2.2.目录结构](#22目录结构)
  - [2.3.ReadMe 说明](#23readme-说明)
  - [2.4.关于第三方引用](#24关于第三方引用)
    - [2.4.1.引用额外的python库](#241引用额外的python库)
    - [2.4.2.引用第三方开源代码](#242引用第三方开源代码)
    - [2.4.3.引用其他系统库](#243引用其他系统库)
  - [2.5.提交自检列表](#25提交自检列表)
- [3.维护与交流](#3维护与交流)

<!-- TOC -->

本指导用于明确贡献规范，从而确保众多的开发者能够以一种相对统一的风格和流程参与到本仓库的建设中。

# 1.准备工作

## 1.1.了解贡献协议与流程

你应该优先参考本仓库中的[CONTRIBUTING.md](../CONTRIBUTING.md)说明来理解本仓库的运作方式。

<!--
### 确定自己贡献的目标

如果希望进行贡献，我们推荐你先从一些较为容易的issue开始尝试。你可以从以下列表中寻找一些简单的例如bugfix的工作。

- [wanted bugfix](https://gitee.com/cambriconknight/dev-env-ubuntu/issues?assignee_id=&author_id=&branch=&collaborator_ids=&issue_search=&label_ids=119404373&label_text=&milestone_id=&priority=&private_issue=&program_id=&project_id=cambriconknight%2Fdev-env-ubuntu&project_type=&scope=&sort=&state=open&target_project=)
- (https://gitee.com/cambriconknight/dev-env-ubuntu/issues?assignee_id=&author_id=&branch=&collaborator_ids=&issue_search=&label_ids=119404373&label_text=&milestone_id=&priority=&private_issue=&program_id=&project_id=cambriconknight%2Fdev-env-ubuntu&project_type=&scope=&sort=&state=open&target_project=)

如果你可以完成独立的网络贡献，你可以从以下列表中找到我们待实现的网络列表。

- [wanted implement](https://gitee.com/cambriconknight/dev-env-ubuntu/issues?assignee_id=&author_id=&branch=&collaborator_ids=&issue_search=&label_ids=119404375&label_text=&milestone_id=&priority=&private_issue=&program_id=&project_id=cambriconknight%2Fdev-env-ubuntu&project_type=&scope=&sort=&state=open&target_project=)

> **Notice** 记得在选定issue之后进行一条回复，从而让别人知道你已经着手于此issue的工作。当你完成某项工作后，也记得回到issue更新你的成果。如果过程中有什么问题，也可以随时在issue中更新你的进展。
-->

# 2.代码提交

## 2.1.CodeStyle

参考[CONTRIBUTING.md](../CONTRIBUTING.md)中关于CodeStyle的说明，你应该确保自己的代码与本仓库现有代码风格保持一致。

## 2.2.目录结构

为了保证本仓库中的实现能够提供一种相对统一的使用方法，我们提供了一种基础的**目录结构模板**，你应该基于此结构来组织自己的工程。

```bash
AIFramework                                 # AI框架
└── XXX                                     # 模型名
    ├── README.md                           # 模型说明文档
    ├── requirements.txt                    # 依赖说明文件
    ├── run_convertmodel.sh                 # 一键转换MLU模型脚本
    ├── scripts                             # 脚本文件
    │   ├── ******.sh                       # 其他功能sh脚本
    │   ├── ******.py                       # 其他功能py脚本
    │   ├── eval.py                         # 精度验证脚本
    │   └── run_eval.sh                     # 验证脚本
    ├── models                              # 原始模型定义及权重目录(如: XXXNet.cfg，download_weights.sh等)
    │   ├── XXXNet.py                       # 模型结构定义
    │   ├── download_weights.sh             # 原始模型权重下载脚本
    │   └── mlu                             # 存放转换后的MLU模型
    ├── quantized_mode                      # （可选）用于在框架基础上进行在线逐层/融合推理的代码
    ├── online_infer                        # （可选）用于在框架基础上进行在线逐层/融合推理的代码
    ├── offline_infer                       # （可选）用于在MLU推理设备上进行离线推理的代码
    ├── third_party                         # （可选）第三方代码
    │   └── XXXrepo                         # （可选）完整克隆自第三方仓库的代码(使用git链接的形式，在使用时下载)
    └── clean.sh                            # 恢复环境，清理运行过程中所产生的目录和文件
```

可以参照以下原则，根据自己的需要在模板基础上做一些适配自己实现的修改：

1. 模型根目录下只放置带有`main方法`的可执行脚本，模型的定义文件统一放在`models`目录下，该目录下可以根据自己模型的复杂程度自行组织层次结构。
2. 配置参数应当与网络定义分离，将所有可配置的参数抽离出来，建议使用.yml或.ini格式文件统一定义。
3. 上传内容应当只包含脚本、代码和文档，**不要上传**任何数据集、以及运行过程中所产生的目录和文件。
4. third_party用于存放需要引用的第三方代码，但是不要直接将代码拷贝到目录下上传，而应该使用git链接的形式，在使用时下载。
5. 每个模型的代码应当自成闭包，可以独立的迁移使用，不应当依赖模型目录以外的其他代码。utils内只是通用工具，并非通用函数库。
6. 推理所用到的测试图片放置到`datasets`目录, 生成的结果放置到`test`目录。

## 2.3.ReadMe 说明

每个AI模型都需要一个对应的`README.md`作为说明文档，对当前的模型实现进行介绍，从而向其他用户传递以下信息：

1. 这是个什么模型？来源和参考是什么？
2. 当前的实现包含哪些内容？
3. 如何使用现有的实现？
4. 这个模型表现如何？

对此，我们提供了一个基础的[README模版](./README_TEMPLATE.md)，你应该参考此模版来完善自己的说明文档, 也可以参考其他现有模型的readme。

## 2.4.关于第三方引用

### 2.4.1.引用额外的python库

确保将自己所需要的额外python库和对应版本（如果有明确要求）注明在`requirements.txt`文件。

### 2.4.2.引用第三方开源代码

应该保证所提交的代码是自己原创开发所完成的。

当你需要借助一些开源社区的力量，应当优先引用一些成熟可信的开源项目，同时确认自己所选择的开源项目所使用的开源协议是否符合要求。

当你使用开源代码时，正确的使用方式是通过git地址获取对应代码，并在使用中将对应代码归档在独立的`third_party`目录中，保持与自己的代码隔离。**切勿粗暴的拷贝对应代码片段到自己的提交中。**

### 2.4.3.引用其他系统库

你应该减少对一些独特系统库的依赖，因为这通常意味着你的提交在不同系统中难以复用。

当你确实需要使用一些独特的系统依赖来完成任务时，你需要在说明中指出对应的获取和安装方法。

## 2.5.提交自检列表

你所提交的代码应该经过充分的Review, 可以参考以下checklist进行自查：

- [ ] 代码风格符合规范。
- [ ] 代码在必要的位置添加了注释。
- [ ] 文档已同步修改。
- [ ] 同步添加了必要的测试用例。
- [ ] 所有第三方依赖都已经说明，包括代码引用，python库，数据集，预训练模型等。
- [ ] 工程组织结构符合[目录结构](#目录结构)中的要求。
- [ ] 完成readme编写，通过CI测试。

# 3.维护与交流

我们十分感谢您对本仓库的贡献，同时十分希望您能够在完成一次提交之后持续关注您所提交的代码。 您可以在所提交模型的README中标注您的署名与常用邮箱等联系方式，并持续关注您的gitee、github信息。

其他的开发者也许会用到您所提交的模型，使用期间可能会产生一些疑问，此时就可以通过issue、站内信息、邮件等方式与您进行详细的交流。
