#!/usr/bin/env bash

set -euo pipefail

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

GIVE_UP_TIME=10                                    # automatically shutdown after 10 mins
DESTINATION_MIN_SIZE=$((32 * 1024 * 1024 * 1024))  # minimum size (in bytes) that we will accept as a valid backup destination
SOURCE_PATH="/mnt/source"                          # where should we mount the sd card?
DESTINATION_PATH="/mnt/destination"                # where should we mount the backup destination?
SHUTDOWN=0                                         # should we shutdown the system when we finish?
VERBOSE=0                                          # set to 1 for additional logging


debug() {
    local msg=$1
    shift

    if [ "$VERBOSE" -eq 1 ]; then
        echo $msg
    fi
}

trigger_led() {
    local mode=$1
    shift

    case "$mode" in
        [0-9]*)
            echo timer > /sys/class/leds/led0/trigger
            echo $mode > /sys/class/leds/led0/delay_on
            ;;
        *)
            echo $mode > /sys/class/leds/led0/trigger
            ;;
    esac
}

mount_filesystems() {
    # Busy loop waiting for devices to come up

    local source_dev=""
    local source_uuid=""
    local destination_dev=""

    while true; do
        if [ ! -z "$source_dev" -a ! -z "$destination_dev" ]; then
            # Woo! We found a valid backup pair
            break
        fi

        # Find mountable filesystems
        while read fs; do
            local fs_name=$(echo $fs | jq -r '.name')
            local fs_type=$(echo $fs | jq -r '.type')
            local fs_fstype=$(echo $fs | jq -r '.fstype')
            local fs_label=$(echo $fs | jq -r '.label')
            local fs_uuid=$(echo $fs | jq -r '.uuid')
            local fs_mountpoint=$(echo $fs | jq -r '.mountpoint')
            local fs_size=$(echo $fs | jq -r '.size')
            local fs_pkname=$(echo $fs | jq -r '.pkname')
            local fs_vendor=$(cat /sys/block/${fs_pkname#*/dev/}/device/vendor 2>/dev/null | awk '{$1=$1};1')
            local fs_model=$(cat /sys/block/${fs_pkname#*/dev/}/device/model 2>/dev/null | awk '{$1=$1};1')

            if [ "$fs_type" != "part" ]; then
                debug "Skipping $fs_name because it as $fs_type"
                continue
            fi

            if [ "$fs_mountpoint" != "null" ]; then
                debug "Skipping $fs_name because it is mounted as $fs_mountpoint"
                continue
            fi

            if [ "$fs_label" == "EOS_DIGITAL" ]; then
                if [ "$fs_fstype" == "vfat" -o "$fs_fstype" == "exfat" ]; then
                    if [ "$source_dev" != "$fs_name" ]; then
                        echo "Found a canon SD card ($fs_vendor $fs_model) at $fs_name"
                        source_dev=$fs_name
                        source_uuid=$fs_uuid
                    fi
                else
                    debug "Skipping $fs_name because it's a $fs_fstype filesystem, not exfat or fat"
                fi
            elif [ "$fs_fstype" == "ntfs" ]; then
                if [ "$fs_size" -ge "$DESTINATION_MIN_SIZE" ]; then
                    if [ "$destination_dev" != "$fs_name" ]; then
                        echo "Found a USB hard drive ($fs_vendor $fs_model) to backup to at $fs_name"
                        destination_dev=$fs_name
                    fi
                else
                    debug "Skipping $fs_name because it's too small ($fs_size < $DESTINATION_MIN_SIZE)"
                fi
            fi

        done <<<$(lsblk -n -l -p -b -J -o NAME,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINT,SIZE,PKNAME | jq -c ".blockdevices[]")

        sleep 1
    done

    # Mount our filesystems
    mkdir -p "${SOURCE_PATH}"
    mkdir -p "${DESTINATION_PATH}"
    mount ${source_dev} ${SOURCE_PATH}
    mount ${destination_dev} ${DESTINATION_PATH}

    UUID="$source_uuid"
}

do_backup() {
    rsync -avP "${SOURCE_PATH}/" "${DESTINATION_PATH}/${UUID}"
}

unmount_fs() {
    # Be extra careful and run a few syncs
    sync && umount "${DESTINATION_PATH}"
    sync && umount "${SOURCE_PATH}"
    sync
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (sudo $0)"
   exit 1
fi

# Set the ACT LED to heartbeat
trigger_led 1000

# Shutdown after a specified period of time (in minutes) if no device is connected.
shutdown -h ${GIVE_UP_TIME} "Shutdown is activated. To cancel: sudo shutdown -c"

# Wait for a USB storage devices
echo "Waiting for SD card and hard drive to be plugged in"
UUID=""
mount_filesystems

# Cancel shutdown
shutdown -c

# Set the ACT LED to blink at 500ms to indicate that the backup has begun
trigger_led 10

# Perform the backup
echo "Starting backup"
do_backup $UUID
echo "Backup finished"

# Unmount filesystems
unmount_fs

# Shutdown
if [ "$SHUTDOWN" -eq 1 ]; then
    shutdown -h now
fi
