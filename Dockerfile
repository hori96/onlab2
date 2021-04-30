FROM ubuntu:18.04

ENV OPENCV_VERSION 3.2.0
ENV OPENCV_DOWNLOAD_URL https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip
ENV OpenCV_DIR opencv-$OPENCV_VERSION

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential \
  cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
  curl \ 
  unzip \
  gcc \
  git \
  xterm \
  wget \
  python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev libjasper-dev \
  libglew-dev libboost-all-dev libssl-dev \
  libeigen3-dev

# install OpenCV
RUN curl -fsSL "$OPENCV_DOWNLOAD_URL" -o opencv.zip \
  && unzip opencv.zip \
  && rm opencv.zip \
  && cd $OpenCV_DIR \
  && mkdir release \
  && cd release \
  && cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local .. \
  && make \
  && make install

# install Pangolin
RUN git clone https://github.com/stevenlovegrove/Pangolin.git \
  && cd Pangolin \
  && mkdir build \
  && cd build \
  && cmake ..\
  && cmake --build .

# install ros melodic
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
  && apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
  && apt update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y ros-melodic-desktop-full \
  && echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN ["/bin/bash", "-c", "source ~/.bashrc"]
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential \
  && apt-get install python-rosdep \
  && rosdep init \
  && rosdep update \
  && echo "export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:/ORB_SLAM3/Examples/ROS" >> ~/.bashrc

# download fixes and new features
RUN git clone https://github.com/hori96/onlab2.git onlab2

# download ORB-SLAM3
RUN git clone https://github.com/UZ-SLAMLab/ORB_SLAM3.git ORB_SLAM3 \
  && cd ORB_SLAM3 \
  && git checkout ef9784101fbd28506b52f233315541ef8ba7af57
  # && ./build.sh \
  # && build_ros.sh

# add fixes and new code
RUN cp /onlab2/System.cc /ORB_SLAM3/src/
RUN cp /onlab2/LoopClosing.h /ORB_SLAM3/include/

# build ORB-SLAM
# build it more times to get it succesfull
# do not throw error if build fails
RUN cd ORB_SLAM3 \
  && ./build.sh || true \
  && cd build \
  && cmake .. -DCMAKE_BUILD_TYPE=Release \
  && make -j || true \
  && make -j || true \
  && make -j || true

# build ORB-SLAM3 ROS
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash ;\
                  export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:/ORB_SLAM3/Examples/ROS; \
                  cd ORB_SLAM3; \
                  ./build_ros.sh || true; \
                  ./build_ros.sh || true; \
                  ./build_ros.sh || true"

# Download test dataset
# optional
RUN mkdir -p Datasets/EuRoc \
  && cd Datasets/EuRoc/ \
  && wget -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.zip \
  && mkdir MH01 \
  && unzip MH_01_easy.zip -d MH01/

# Download ROS test dataset
# optional
RUN wget -c http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/vicon_room1/V1_02_medium/V1_02_medium.bag \
 && mv V1_02_medium.bag /Datasets/

VOLUME ["/ORB_SLAM3/"]
