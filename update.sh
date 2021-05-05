#!/bin/bash

git clone https://github.com/topjohnwu/Magisk

export ANDROID_SDK_ROOT=/mnt/c/Users/smook/AppData/Local/Android/Sdk

cd Magisk

./build.py ndk
./build.py binary

