#!/bin/bash
set -e


# 清理所有停止运行的容器：
#sudo docker container prune
# or
#sudo docker rm $(sudo docker ps -aq)
# 清理已经退出的docker容器
sudo docker rm $(sudo docker ps -a -q --filter status=exited)

# 清理所有悬挂（<none>）镜像：
sudo docker image prune
# or
#sudo docker rmi $(sudo docker images -qf "dangling=true")

# 清理所有无用数据卷：
#sudo docker volume prune

## 由于prune操作是批量删除类的危险操作，所以会有一次确认。 如果不想输入y<CR>来确认，可以添加-f操作。慎用！

# 清理已经退出的docker容器
#sudo docker rm $(sudo docker ps -a -q --filter status=exited)

# 统计docker容器数量
#sudo docker ps -a | wc -l

#删除所有停止运行的容器
#sudo docker container prune

# 统计docker镜像docker数量
#sudo docker images | wc -l

# 删除所有未被容器使用的镜像:
# docker image prune -a