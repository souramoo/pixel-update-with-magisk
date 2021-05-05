# pixel-update-with-magisk

Just a simple script to run from a Linux (or WSL2 under Windows) with your phone connected to update your Pixel 5 to the latest OTA and also patch in Magisk to preserve root all in one go.

A convenience for me :)

## To use:
Change the export ANDROID_SDK variable in update.sh and then just run it!

It will:

- clone and compile latest magisk
- get latest OTA zip from google
- extract all to temp folder
- replace -w command so you don't wipe your data
- put device into fastboot mode
- execute commands to replace firmware
- patch boot.img
- flash boot.img
- reboot phone
