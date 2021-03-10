# Containerize-YOLOv3-Ray-on-ARM64


## Install Nvidia Pytorch-L4t docker image:

Reference: https://ngc.nvidia.com/catalog/containers/nvidia:l4t-pytorch
* JetPack 4.4 (L4T R32.4.3)

  * l4t-pytorch:r32.4.3-pth1.6-py3
  * PyTorch v1.6.0-rc2
  * torchvision v0.7.0-rc2

`docker pull nvcr.io/nvidia/l4t-pytoch:r32.4.3-pth1.6-py3`

**Run docker image**

`sudo docker run -it --rm --device /dev/video0 --net=host --runtime nvidia  -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-pytorch:r32.4.3-pth1.6-py3`

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
OpenCV 4.1.1 is installed in Jetson by default, but without CUDA support. Run installOpenCV.sh to compile & install OpenCV 4.4.0 from source.

`./installOpenCV /usr/local`

## Install Darknet:
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

* Download yolov3 model:

 `wget https://pjreddie.com/media/files/yolov3.weights  `

  `wget https://pjreddie.com/media/files/yolov3-tiny.weights`

* `xhost+`  on host before test yolov3 in container

* Test YOLOv3 with any image under data folder:

  `./darknet detect cfg/yolov3-tiny.cfg yolov3-tiny.weights data/dog.jpg`

* Test YOLOv3 using usb webcam:

    `./darknet detector demo cfg/coco.data cfg/yolov3.cfg yolov3.weights`


## Install YOLOv3 ##
```

git clone https://github.com/ultralytics/yolov3

pip install -r requirements.txt

```

Add `import torch` at the top of `detect.py`



Test:

 **YOLOv3:**  `python3 detect.py --cfg cfg/yolov3.cfg --weights yolov3.pt`

 **YOLOv3-tiny:**  `python3 detect.py --cfg cfg/yolov3-tiny.cfg --weights yolov3-tiny.pt` 

 **YOLOv3-SPP:**  `python3 detect.py --cfg cfg/yolov3-spp.cfg --weights yolov3-spp.pt`

 **Webcam:**  `python3 detect.py --source 0 --device 0 --cfg cfg/yolv3.cfg --weights yolov3.pt`


## Set up Ray environment

**Install Archiconda**

Archiconda is an ARM64 alternative for Anaconda:

```
wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
```

After downloading the script, use `bash Archiconda3-0.2.3-Linux-aarch64.sh` for installation. By default Archiconda use Python3.7 and will add its own `PYTHONPATH` to `.bashrc`. This conflicts with the Nvidia L4T-Pytorch default python3.6, and will become a trouble in the future because our pytorch1.6 only works with Python3.6. A little walkaround to solve this is to add `alias python3='/usr/bin/python3.6'` and `alias python='/usr/bin/python3.6'` to `~/.bashrc`. Then, `source ~/.bashrc`.

**Install Bazel**

```
apt-get install pkg-config zip g++ zlib1g-dev unzip python3
apt-get update
apt install openjdk-11-jdk
```

Set JDK address:

find `/usr/lib/jvm/java-1.x.x-openjdk`

`vim /etc/profile`

add `export JAVA_HOME="path that you found"` `export PATH=$JAVA_HOME/bin:$PATH`


Currently bazel 3.2.0 is used for CI in ray team, so download bazel 3.2.0 release package from [Github](https://github.com/bazelbuild/bazel/releases ), make sure you download package `bazel-3.2.0-dist.zip`. 

Unzip the downloaded zip file into a new folder `bazel`: 
`unzip  bazel-3.2.0-dist.zip -d bazel`

`cd bazel`

Then compile:

`bash ./compile.sh`

After compilation, copy the binary of bazel into `/usr/local/bin`:

`cp /output/bazel /usr/local/bin`

**Install py-spy**

```
cd /opt/builds

git clone https://github.com/benfred/py-spy

git checkout -b 0.3.3 929f213

pip3 install -e . --verbose

```


**Install ray**

 ```
   cd /opt/builds
   git clone https://github.com/ray-project/ray
   cd ray/python
   pip3 install -e . --verbose

```
