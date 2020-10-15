OPENCV_VERSION=4.4.0		#Update accordingly
NUM_JOBS=$(nproc)		#Number of processor to use

#Default location is /usr/local
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <Install Folder>"
    exit
fi
folder="$1"

chip_id=$(cat /sys/module/tegra_fuse/parameters/tegra_chip_id)
case ${chip_id} in
  "33" )  # Nano and TX1
    cuda_compute=5.3
    ;;
  "24" )  # TX2
    cuda_compute=6.2
    ;;
  "25" )  # AGX Xavier
    cuda_compute=7.2
    ;;
  * )     # default
    cuda_compute=5.3,6.2,7.2
    ;;
esac

echo "** Remove other OpenCV first"
sudo apt-get purge libopencv*

echo "** Install requirement"
apt-get update
apt-get install -y build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
apt-get install -y python2.7-dev python3.6-dev python-dev python-numpy python3-numpy
apt-get install -y libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev
apt-get install -y libv4l-dev v4l-utils qv4l2 v4l2ucp
apt-get install -y qt5-default 
apt-get update

echo "** Download opencv-4.4.0"
cd $folder
git clone --branch "$OPENCV_VERSION" https://github.com/opencv/opencv.git
git clone --branch "$OPENCV_VERSION" https://github.com/opencv/opencv_contrib.git

#Rename dir
mv opencv opencv-${OPENCV_VERSION}
mv opencv_contrib opencv_contrib-${OPENCV_VERSION}
cd opencv-${OPENCV_VERSION}/

echo "** Building..."
mkdir -p release
cd release/

echo $(pwd)
time cmake -D WITH_CUDA=ON \
-D WITH_CUDNN=ON \
-D WITH_CUDA=ON \
-D CUDA_ARCH_BIN=${cuda_compute} \
-D CUDA_ARCH_PTX="" \
      -D ENABLE_FAST_MATH=ON \
      -D CUDA_FAST_MATH=ON \
      -D CUDNN_VERSION='8.0'\  # make sure to add this line or OpenCV will not find cuDNN lib when compiling
      -D WITH_CUBLAS=ON \
      -D WITH_CUDNN=ON \
      -D WITH_LIBV4L=ON \
      -D WITH_V4L=ON \
      -D WITH_GSTREAMER=ON \
      -D WITH_GSTREAMER_0_10=OFF \
 -D WITH_QT=ON \
      -D WITH_OPENGL=ON \
      -D WITH_EIGEN=ON \
      -D WITH_OPENMP=ON \
      -D WITH_NVCUVID=ON \
      -D OPENCV_DNN_CUDA=ON \
-D BUILD_opencv_python2=ON \
-D BUILD_opencv_python3=ON \
-D BUILD_TESTS=OFF \
-D BUILD_PERF_TESTS=OFF \
-D BUILD_EXAMPLES=OFF \
-D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/usr/local \
-D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-${OPENCV_VERSION}/modules \
..

time make -j$NUM_JOBS
time make install
echo '# Add OpenCV lib to pypath' >> ~/.bashrc
echo 'export PYTHONPATH=$PYTHONPATH:'$PWD'/python_loader/' >> ~/.bashrc	#Add python path
source ~/.bashrc

# check installation
IMPORT_CHECK="$(python3 -c "import cv2 ; print(cv2.__version__)")"
if [[ $IMPORT_CHECK != *$OPENCV_VERSION* ]]; then
  echo "There was an error loading OpenCV in the Python sanity test."
  echo "The loaded version does not match the version built here."
  echo "Please check the installation."
  echo "The first check should be the PYTHONPATH environment variable."
else
  echo "** Installed opencv-$OPENCV_VERSION successfully! **"
fi
