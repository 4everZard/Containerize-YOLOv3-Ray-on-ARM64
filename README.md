# Containerize-YOLOv3-Ray-on-ARM64


## Install Nividia Pytorch-L4t docker image:

Reference: https://ngc.nvidia.com/catalog/containers/nvidia:l4t-pytorch
* JetPack 4.4 (L4T R32.4.3)

  * l4t-pytorch:r32.4.3-pth1.6-py3
  * PyTorch v1.6.0-rc2
  * torchvision v0.7.0-rc2

`docker pull nvcr.io/nvidia/l4t-pytoch:r32.4.3-pth1.6-py3`

**Run docker image**

`sudo docker run -it --rm --privileged --net=host --runtime nvidia  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-pytorch:r32.4.3-pth1.6-py3`

**check CUDA version:**

`nvcc -V`

**check cuDNN version:**

`cat /usr/include/cudnn_version.h | grep CUDNN_MAJOR -A 2`

**Note: Ensure that the CUDA compiler (nvcc) is added to ~/.bashrc**
```
$ echo '# Append CUDA tools path' >> ~/.bashrc
$ echo 'export PATH=/usr/local/cuda-10.2/bin${PATH:+:${PATH}}'>> ~/.bashrc
$ echo 'export LD_LIBRARY_PATH=/usr/local/cuda-10.2/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'>> ~/.bashrc
$ echo 'export CUDA_INCLUDE_DIRS=/usr/local/cuda-10.2/include'>> ~/.bashrc
$ echo 'export CUDA_ROOT_ENV=/usr/local/cuda-10.2'>> ~/.bashrc
```

test CUDA by running `./makeCUDAsample.sh` to compile samples：


## Install jetson-stats:
jetson-stats is a tool to monitoring and control your NVIDIA Jetson Board. 

`pip3 install -U jetson-stats`

After jetson-stats installed, we can run `jtop` on host to monitor the CPU/GPU activities or run `jetson_release -v` in host/container to show the status about your Nvidia Jetson.  

## Install OpenCV4:
OpenCV 4.1.1 is installed in Jetson Nano by default, but without CUDA support. Run installOpenCV.sh to compile & install OpenCV 4.4.0 from source.

`./installOpenCV /usr/local`

## Install YOLOv3:
```
mkdir -p ~/dl/darknet
cd ~/dl/darknet
git clone https://github.com/pjreddie/darknet.git
cd darknet
```

**After installation, change Makefile by:**
```
GPU=1
CUDNN=1
OPENCV=1
OPENMP=1
DEBUG=1

ARCH= -gencode arch=compute_72,code=[sm_72,compute_72]

NVCC=/usr/local/cuda-10.2/bin/nvcc
```

**Compile:** 
`make -j8`

If you get `usage: ./darknet` after running `./darknet`, you are done with YOLOv3 installation!

**Test YOLOv3：**

Download yolov3-tiny model:
`wget https://pjreddie.com/media/files/yolov3-tiny.weights`

`xhost+`  on host before test yolov3 in container

test YOLOv3 with any image under data folder:
`./darknet detect cfg/yolov3-tiny.cfg yolov3-tiny.weights data/dog.jpg`


## Install Ray

