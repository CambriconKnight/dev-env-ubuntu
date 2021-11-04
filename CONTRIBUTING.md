<p align="center">
    <a href="https://gitee.com/cambriconknight/dev-env-ubuntu">
        <h1 align="center"> 贡献指南 </h1>
    </a>
</p>

<!-- TOC -->

- [1.开始](#1开始)
- [2.贡献流程](#2贡献流程)
  - [2.1.代码风格](#21代码风格)
  - [2.2.Fork-Pull开发模式](#22fork-pull开发模式)
  - [2.3.报告问题](#23报告问题)
    - [2.3.1.issue标签](#231issue标签)
    - [2.3.2.issue格式](#232issue格式)
  - [2.4.提交PR](#24提交pr)

<!-- /TPC -->

# 1.开始

- 可以在[github](https://github.com/CambriconKnight/dev-env-ubuntu)或者[Gitee](https://gitee.com/cambriconknight/dev-env-ubuntu)仓库上进行Fork。
- 阅读[README.md](README.md)来获取仓库信息和编译步骤。

# 2.贡献流程

## 2.1.代码风格

为了仓库易于审核、维护和开发，请遵循如下规范

- 代码规范

    *Python*代码风格可以参考[Python PEP 8 Coding Style](https://pep8.org/)，*C++* 代码规范可以参考[Google C++ Coding Guidelines](http://google.github.io/styleguide/cppguide.html)。
    可以使用[CppLint](https://github.com/cpplint/cpplint)，[CppCheck](http://cppcheck.sourceforge.net)，[CMakeLint](https://github.com/cmake-lint/cmake-lint), [CodeSpell](https://github.com/codespell-project/codespell), [Lizard](http://www.lizard.ws), [ShellCheck](https://github.com/koalaman/shellcheck) 和 [PyLint](https://pylint.org)，进行代码格式检查，建议将这些插件安装在你的IDE上。

- 单元测试

    *Python*单元测试风格建议采用[pytest](http://www.pytest.org/en/latest/)；
    *C++* 单元测试建议采用[Googletest Primer](https://github.com/google/googletest/blob/master/docs/primer.md)。
    测试用例的测试目的应该在命名上体现。

- 重构

    鼓励各位大佬重构我们的代码，来消除[code smell](https://en.wikipedia.org/wiki/Code_smell)。所有的代码都必须经过代码风格检验、测试检验，重构代码也不例外。[Lizard](http://www.lizard.ws)阈值，对于nloc((lines of code without comments)是100，cnc (cyclomatic complexity number)是20，如果你收到一个*Lizard*警告，你必须在合入仓库前重构你的代码。

- 文档

    我们使用*MarkdownLint*来检查markdown文档的格式。

    具体细节，请参考[RULES](https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md)。

## 2.2.Fork-Pull开发模式

详细操作步骤参考寒武纪开发者论坛[手把手教你如何为CNStream开源项目做贡献](http://forum.cambricon.com/index.php?m=content&c=index&a=show&catid=47&id=252)

基本步骤如下:

- Fork仓库

    在提交本仓库项目代码之前，请确保本仓库已经被fork到你自己的仓库当中，这可以使得本仓库和你的仓库并行开发，因此请确保两者之间的一致性。

- Clone远程仓库

    如果你想下载代码到你的本地机器，请使用git。

    ```shell
    # For GitHub
    git clone https://github.com/{your_name}/dev-env-ubuntu.git
    git remote add upstream https://github.com/CambriconKnight/dev-env-ubuntu.git
    # For Gitee
    git clone https://gitee.com/{your_name}/dev-env-ubuntu.git
    git remote add upstream https://github.com/CambriconKnight/dev-env-ubuntu.git
    ```

- 本地代码开发

   为了保证并行分支之间的一致性，在开发代码前请创建一个新的分支：

    ```shell
    git checkout -b {new_branch_name} origin/master
    ```

   说明：origin 为官方仓库，注意在创建自己仓库时尽量避免出现origin关键字，以免出现混淆

- 推送代码到远程仓库

    在更新代码之后，你需要按照如下方式来推送代码到远程仓库：

    ```shell
    git add .
    git status
    git commit -m "Your commit info"
    git commit -s --amend
    git push origin {new_branch_name}
    ```

- 对本仓库提交推送请求--提交PR

    在最后一步，你需要在你的新分支和本仓库`master`分支提交一个比较请求。在这之后，Jenkins门禁会自动运行创建测试，之后你的代码会被合入到远程主仓分支上。

## 2.3.报告问题

当你遇到一个问题时,提交一个详细的问题单会对本仓库有很大的贡献，我们永远欢迎填写详细、全面的[issue](https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/issues)。

### 2.3.1.issue标签

| 标签                   | 使用阶段	                         | 说明                                  |
| :-------------------- | :------------------------------- | :----------------------------------  |
| bug                   | 新建issue时                       | 因代码引起的bug                        |
| enhancement           | 新建issue时                       | 原来系统有此功能，需要完善、升级          |
| feature               | 新建issue时                       | 原来系统没有此功能，需要新增加的功能       |
| duplicate             | 评审issue时                       | 已经有类似issue                       |
| invalid               | 评审issue时                       | 不存在所描述的问题，或不需要进行该任务     |
| question              | 评审issue时                       | 问题交流                              |
| wontfix               | 评审issue时                       | 因为客观原因，无法进行的任务             |

### 2.3.2.issue格式

当报告issue时，参考下面的格式：

- 你使用的环境(os、caffe/python、driver、cntoolkit等)是什么版本的
- 这是一个BUG REPORT还是一个FEATURE REQUEST
- 这个问题的类型是什么，在issue dashbord上添加标签并进行高亮
- 发生了什么问题
- 你期望的结果是什么
- 如何复现
- 必要的注释

**issues 警告:**

**如何确定哪一个issue是你要解决的？** 请添加一些commits在这个issue上，以此来告诉其他人你将会处理它。

**如果一个issue已经被打开一段时间了，** 建议在动手解决这个issue之前先检查一下是否还存在。

**如果你解决了一个你自己提的issue，** 在关闭之前需要让其他人知道。

具体可以参照该[链接](https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/issues)下已经提交的issue示例

## 2.4.提交PR

- 在 [GitHub](https://github.com/CambriconKnight/dev-env-ubuntu/issues) 或者 [Gitee](https://gitee.com/cambriconknight/mlu220-cross-compile-docker-image/issues) 针对一个*issue*提出你的解决方案。
- 在议题讨论和设计方案审核达成共识后，fork后完成开发后提交PR
- 贡献者的代码需要至少两个committer*LGTM*，PR才可以被允许推送，注意贡献者不允许在自己的PR上添加*LGTM*。
- 在PR被详细评审后，这个PR将会被确定能否被合入。

**提交PR时注意事项:**

- 应避免任何无关的更改
- 确保您的提交历史记录只有一次，在确定是最终版提交记录后，将以往提交记录合并。
- 始终保持你的分支与主分支一致。
- 对于修复bug的PR，请确保链接上了issue
