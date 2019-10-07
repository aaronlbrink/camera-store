#!/bin/bash
# mount
mount /dev/sdcard1 /mnt/sd-card
mount /dev/ssdstorage1 /mnt/ssd-storage
sleep 2


# GPIO 
https://medium.com/coinmonks/controlling-raspberry-pi-gpio-pins-from-bash-scripts-traffic-lights-7ea0057c6a90

# GPIO Pin assignments
BASE_GPIO_PATH=/sys/class/gpio
YELLOW=10
GREEN=11

# Assign names to states
ON="1"
OFF="0"

exportPin()
{
  if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
    echo "$1" > $BASE_GPIO_PATH/export
  fi
}

# Utility function to set a pin as an output
setOutput()
{
  echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Utility function to change state of a light
setLightState()
{
  echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Utility function to turn all lights off
allLightsOff()
{
  setLightState $RED $OFF
  setLightState $YELLOW $OFF
  setLightState $GREEN $OFF
}


SDROOT=/mnt/sd-card/DCIM
FOLDERS=$SDROOT/*

# turn all lights off to start
allLightsOff
for folder in $FOLDERS
do
    FILES=$SDROOT/$folder/*
    for f in $FILES
        do
        echo "Processing $f file..."
        # take action on each file. $f store current file name
        cp $f /mnt/ssd-storage/$f
        
        # byte-by-byte comparison to ensure everything copied over
        if ! cmp /mnt/ssd-storage/$f $SDROOT/$folder/$f; then
            # Comparison error 
            echo "Comparison Error"
            setLightState $YELLOW $ON
            sleep 6
            exit 1
        fi
        
        # Remove file from SD Card to free space
        if ! rm $f; then
            echo "Removing the file failed somehow"
            setLightState $YELLOW $ON
            sleep 6
            exit 1
        fi
     done
done
