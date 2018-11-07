#!/bin/bash

## Bash script for setting up a PX4 development environment on Ubuntu LTS (18.04).
## It can be used for installing simulators (only) or for installing the preconditions for Snapdragon Flight or Raspberry Pi.
##
## Installs:
## - Common dependencies and tools for all targets (including: Ninja build system, Qt Creator, pyulog)
## - FastRTPS and FastCDR
## - jMAVSim simulator dependencies

# Preventing sudo timeout https://serverfault.com/a/833888
trap "exit" INT TERM; trap "kill 0" EXIT; sudo -v || exit $?; sleep 1; while true; do sleep 60; sudo -nv; done 2>/dev/null &
cpucores=$(( $(lscpu | grep Core.*per.*socket | awk -F: '{print $2}') * $(lscpu | grep Socket\(s\) | awk -F: '{print $2}') ))

# Ubuntu Config
echo "We must first remove modemmanager"
sudo apt-get remove modemmanager -y


# Common dependencies
echo "Installing common dependencies"
sudo apt-get update -y
sudo apt-get install git zip qtcreator cmake build-essential genromfs ninja-build exiftool -y
# Required python packages
sudo apt-get install python-argparse python-empy python-toml python-numpy python-dev python-pip -y
sudo -H pip install --upgrade pip
sudo -H pip install pandas jinja2 pyserial
# optional python tools
sudo -H pip install pyulog

# Install FastRTPS and FastCDR
fastrtps_dir=$HOME/Fast-CDR
echo "Installing FastRTPS to: $fastrtps_dir"
if [ -d "$fastrtps_dir" ]
then
    echo "FastRTPS already installed."
else
    pushd .
    cd ~
    git clone git@github.com:eProsima/Fast-RTPS.git $fastrtps_dir
    cd $fastrtps_dir
    git clone git@github.com:eProsima/Fast-CDR.git Fast-CDR
    
    mkdir build
    cd build
    cmake ..
    make -j8
    sudo make install

    cd ../Fast-CDR
    mkdir build
    cd build
    cmake ..
    make -j8
    sudo make install
    popd
fi

# jMAVSim simulator dependencies
echo "Installing jMAVSim simulator dependencies"
sudo apt-get install ant openjdk-8-jdk openjdk-8-jre -y