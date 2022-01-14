#/bin/bash
export MY_CONTAINER="ubuntu18.04-yolov5_v1.0-`whoami`"
num=`sudo docker ps -a|grep -w "$MY_CONTAINER$"|wc -l`
echo $num
echo $MY_CONTAINER
if [ 0 -eq $num ];then
sudo xhost +
sudo docker run \
  -e DISPLAY=unix$DISPLAY --net=host --ipc=host --pid=host \
  -v /sys/kernel/debug:/sys/kernel/debug \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -it --privileged --name $MY_CONTAINER \
  -v /data:/data \
  -v $PWD/../../../../:/home/share ubuntu18.04-yolov5:v1.0 /bin/bash
else
sudo docker start $MY_CONTAINER
sudo docker exec -ti $MY_CONTAINER /bin/bash
fi
