build:

docker build -t orb3 .
Error eseten ujra futtatni make -j (ORB_SLAM3/build mappaban) vagy build.sh (ORB_SLAM3 mappaban) parancsot amig teljesen sikerul
Ha ROS is kell:
build_ros.sh amig nem sikerul (ORB_SLAM3 mappaban)

run:

xhost +local:docker
# docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix  orb3
docker run -it --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix orb3

teszt (letoltott euroc dataset-el):

# Mono
./Examples/Monocular/mono_euroc ./Vocabulary/ORBvoc.txt ./Examples/Monocular/EuRoC.yaml /Datasets/EuRoc/MH01 ./Examples/Monocular/EuRoC_TimeStamps/MH01.txt dataset-MH01_mono
# Mono + Inertial
./Examples/Monocular-Inertial/mono_inertial_euroc ./Vocabulary/ORBvoc.txt ./Examples/Monocular-Inertial/EuRoC.yaml /Datasets/EuRoc/MH01 ./Examples/Monocular-Inertial/EuRoC_TimeStamps/MH01.txt dataset-MH01_monoi
# Stereo
./Examples/Stereo/stereo_euroc ./Vocabulary/ORBvoc.txt ./Examples/Stereo/EuRoC.yaml /Datasets/EuRoc/MH01 ./Examples/Stereo/EuRoC_TimeStamps/MH01.txt dataset-MH01_stereo
# Stereo + Inertial
./Examples/Stereo-Inertial/stereo_inertial_euroc ./Vocabulary/ORBvoc.txt ./Examples/Stereo-Inertial/EuRoC.yaml /Datasets/EuRoc/MH01 ./Examples/Stereo-Inertial/EuRoC_TimeStamps/MH01.txt dataset-MH01_stereoi

ROS teszt (letoltott rosbag dataset-el):

1. terminal
xhost +local:docker
# docker run -it --rm -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix  orb3
docker run -it --rm -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix orb3
cd ORB_SLAM3
rosrun ORB_SLAM3 Stereo_Inertial Vocabulary/ORBvoc.txt Examples/Stereo-Inertial/EuRoC.yaml true

2. terminal
docker exec -it <container_id> bash
roscore

3. terminal
docker exec -it <container_id> bash
cd Datasets
rosbag play --pause V1_02_medium.bag /cam0/image_raw:=/camera/left/image_raw /cam1/image_raw:=/camera/right/image_raw /imu0:=/imu
(meg kell nyomni space-t az inditashoz)



Kamera kalibralas:
pattern.png-t kinyomtatni, legalabb 12-15 kep rola a kalibralando kameraval

cd onlab2
python calibrate.py
(31. sorban meg kell adni a mappa eleresi utjat ahol a kepek vannak)

eredmenyek ertelmezese:
kamera matrix:
fx 0  cx
0  fy cy
0  0  1
distortion coefficients:
k1, k2, p1, p2, k3, k4, k5, k6

Ezek alapjan kell egy uj yaml fajl. Pelda: ORB_SLAM3/Examples/Monocular/EuRoC.yaml


ORB-SLAM3 hasznos linkek:
https://github.com/UZ-SLAMLab/ORB_SLAM3
https://github.com/Mauhing/ORB_SLAM3/blob/master/README.md

