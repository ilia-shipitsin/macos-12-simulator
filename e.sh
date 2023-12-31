#!/bin/sh

SDK_PLATFORM=30

# install the x86 SDK package
echo "Download android image"
echo y | "$ANDROID_HOME/tools/bin/sdkmanager" "system-images;android-${SDK_PLATFORM};google_apis;x86_64"

# create the Android Virtual Device using the given SDK package
echo "Create AVD"
echo no | "$ANDROID_HOME/tools/bin/avdmanager" create avd -n TestAvd -k "system-images;android-${SDK_PLATFORM};google_apis;x86_64"

echo "AVD created:"
"$ANDROID_HOME/emulator/emulator" -list-avds

echo "Starting the Android emulator..."
export ANDROID_EMULATOR_DEBUG=1
nohup "$ANDROID_HOME/emulator/emulator" -avd TestAvd -no-snapshot-load 2>&1 &

EMU_BOOTED='unknown'
n=0

echo "Waiting for device 45 sec..."
sleep 45

while
    echo "Waiting android to boot 10 sec..."
    sleep 10
    EMU_BOOTED=`adb shell 'getprop sys.boot_completed'`
    echo "getprop sys.boot_complete=$EMU_BOOTED"
    n=$((n + 1))
    if [ $n -gt 30 ]; then
        echo "Android Emulator does not start in 5 minutes"
        exit 2
    fi
   [[ ${EMU_BOOTED} != *"1"* ]]
   do :
done
echo "Android Emulator started."

echo "Access emulator with adb"

"$ANDROID_HOME/platform-tools/adb" shell ls  2>/dev/null > ls.log

echo "Stop emulator "
adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
sleep 5

if [ -s nohup.out ]; then
   echo "Emulator output:"
   cat nohup.out
fi

if ! grep -q proc ls.log; then
 echo 'Can not access emulator with adb';
 exit 3
fi