#!/bin/bash

## 20min installer for Ubuntu 18.04:
# ROS
# MAVROS
# PX4 Firmware + DEPS

# System update
sudo apt update
sudo apt upgrade -y

## Install ROS melodic
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
sudo apt update
sudo apt install ros-melodic-desktop-full -y
sudo rosdep init
sudo -H rosdep update
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source ~/.bashrc
sudo apt-get install python-catkin-tools python-rosinstall python-rosinstall-generator python-wstool build-essential -y

## Install MAVROS
sudo apt install ros-melodic-mavros ros-melodic-mavros-extras -y

## Install PX4 +DEPS
# Deps
cd ~
sudo apt-get remove modemmanager -y
sudo apt-get install git zip qtcreator cmake build-essential genromfs ninja-build exiftool -y
sudo apt-get install python-argparse python-empy python-toml python-numpy python-dev python-pip -y
sudo apt-get install ant openjdk-8-jdk openjdk-8-jre -y
sudo -H pip install --upgrade pip
sudo -H pip install pandas jinja2 pyserial
sudo -H pip install pyulog

git clone https://github.com/eProsima/Fast-RTPS.git Fast-RTPS --depth=1
cd Fast-RTPS
mkdir build
cd build
cmake -DTHIRDPARTY=ON ..
make -j8
sudo make install
cd ~
rm -rf Fast-RTPS

git clone https://github.com/eProsima/Fast-CDR.git Fast-CDR --depth=1
cd Fast-CDR
mkdir build
cd build
cmake ..
make -j8
sudo make install
cd ~
rm -rf Fast-CDR

# PX4
cd ~
git clone https://github.com/PX4/Firmware.git PX4-Firmware --depth=1
cd PX4-Firmware
make posix_sitl_default gazebo

echo "Done!"