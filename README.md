# Containerize-YOLOv3-Ray-on-ARM64


## Install Nividia Pytorch-L4t docker image:

Reference: https://ngc.nvidia.com/catalog/containers/nvidia:l4t-pytorch
* JetPack 4.4 (L4T R32.4.3)

  * l4t-pytorch:r32.4.3-pth1.6-py3
  * PyTorch v1.6.0-rc2
  * torchvision v0.7.0-rc2

`docker pull nvcr.io/nvidia/l4t-pytoch:r32.4.3-pth1.6-py3`

Run docker image

`sudo docker run -it --rm --privileged --net=host --runtime nvidia  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-pytorch:r32.4.3-pth1.6-py3`

check CUDA version:

`nvcc -V`

check cuDNN version:

`cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2`


## Install jetson-stats:
jetson-stats is a tool to monitoring and control your NVIDIA Jetson Board. 

`pip3 install -U jetson-stats`

After jetson-stats installed, we can run `jtop` on host to monitor the CPU/GPU activities or run `jetson_release -v` in host/container to show the status about your Nvidia Jetson.  

## Install OpenCV4:


