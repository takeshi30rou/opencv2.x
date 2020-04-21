FROM ubuntu:16.04

RUN apt-get update \
  && apt-get install -y \
      python2.7 python-pip
RUN pip install --upgrade pip \
  && pip install numpy

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavresample-dev \
    libjpeg-dev \
    libpng-dev \
    libswscale-dev \
    libtbb-dev \
    libtiff-dev \
    libv4l-dev \
    pkg-config \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN OPENCV_VERSION="2.4.13.6" \
  && mkdir -p /tmp/opencv \
  && cd /tmp/opencv/ \
  && wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -q \
  && unzip ${OPENCV_VERSION}.zip -d . \
  && mkdir /tmp/opencv/opencv-${OPENCV_VERSION}/build \
  && cd /tmp/opencv/opencv-${OPENCV_VERSION}/build/ \
  && cmake \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_TBB=ON \
    -D CMAKE_INSTALL_PREFIX=$(python2.7 -c "import sys; print(sys.prefix)") \
    -D PYTHON_EXECUTABLE=$(which python2.7) \
    -D PYTHON_INCLUDE_DIR=$(python2.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -D PYTHON_PACKAGES_PATH=$(python2.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
    .. \
    | tee /tmp/opencv_cmake.log \
  && make -j "$(nproc)" \
    | tee /tmp/opencv_build.log \
  && make install \
    | tee /tmp/opencv_install.log \
  && rm -rf /tmp/opencv

RUN ln -s \
  /usr/local/python/cv2/python-2.7/cv2.cpython-37m-x86_64-linux-gnu.so \
  /usr/local/lib/python2.7/site-packages/cv2.so
