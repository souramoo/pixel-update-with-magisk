#!/bin/bash

export ANDROID_SDK_ROOT=/mnt/c/Users/smook/AppData/Local/Android/Sdk
export KEEPVERITY=true
export KEEPFORCEENCRYPT=true
export RECOVERYMODE=false

export ADB_LOCATION=$ANDROID_SDK_ROOT/platform-tools/adb*
export FASTBOOT_LOCATION=$ANDROID_SDK_ROOT/platform-tools/fastboot*

alias adb=$ADB_LOCATION
alias fastboot=$FASTBOOT_LOCATION

echo BUILDING MAGISK
cd /tmp/

git clone --recurse-submodules https://github.com/topjohnwu/Magisk.git

cd Magisk

#./build.py ndk
./build.py stub
./build.py binary

echo GETTING LATEST OTA FULL FIRMWARE IMAGE

curl 'https://developers.google.com/android/images' \
  -H 'authority: developers.google.com' \
  -H 'pragma: no-cache' \
  -H 'cache-control: no-cache' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="90", "Google Chrome";v="90"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36' \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'sec-fetch-site: same-site' \
  -H 'sec-fetch-mode: navigate' \
  -H 'sec-fetch-user: ?1' \
  -H 'sec-fetch-dest: document' \
  -H 'referer: https://www.google.com/' \
  -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
  -H 'cookie: CONSENT=YES+GB.en+20161204-19-0; _ga_devsite=GA1.3.4195924775.1610050237; django_language=en; devsite_wall_acks=nexus-image-tos; ' \
  --compressed > dl

wget $(cat dl|grep dl.google.com|grep redfin|tail -n 1 | cut -d'"' -f2) -O firmware.zip

echo EXTRACTING FILES

unzip firmware.zip
mv redfin* redfin
sed -i 's/-w//' redfin/flash-all.sh
sed -i 's/\$(which fastboot)/fastboot/' redfin/flash-all.sh
sed -i 's/bin.sh/bin\/bash/' redfin/flash-all.sh

echo PATCHING BOOT IMG
unzip redfin/image-*.zip boot.img
mv boot.img ./scripts/
cp native/out/x86/* ./scripts/
export PATH=.:$PATH
cp /bin/echo ./scripts/getprop
export OUTFD=1
# arm binaries
cp native/out/arm64-v8a/magisk ./scripts/magisk64
cp native/out/armeabi-v7a/magisk ./scripts/magisk32
cp native/out/armeabi-v7a/magiskinit ./scripts/magiskinit

cd scripts
bash ./boot_patch.sh boot.img
cd ..

echo UPDATING PHONE
adb devices
adb reboot fastboot
sleep 30
cd redfin
cp $FASTBOOT_LOCATION ./fastboot
bash flash-all.sh
cd ..

read -p 

adb reboot fastboot

echo FLASHING PATCHED BOOT
cd scripts
fastboot flash boot new-boot.img
cd ..

