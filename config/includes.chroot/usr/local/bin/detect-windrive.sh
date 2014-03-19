#!/bin/sh

# Creat test mount point
echo "Creating test mount point /tmp/wintest/  ..."
if [ -e "/tmp/wintest/" ]; then
  echo "We already have /tmp/wintest/"
else
  mkdir /tmp/wintest
fi

# Creat detected device list file
echo "Creating detected win-partision list /tmp/win_devices  ..."
echo -n > /tmp/win_devices

# Get user's name
myUserName=$(whoami)

# Start checking
echo "Start detecting win-partisions  ..."
sudo /sbin/fdisk -l | grep -e "NTFS" | grep -v Hidden | cut -c 1-9 | while read line; do
  if mount_result=$(mount -v | grep $line); then
    echo $line $mount_result
  else
        echo $line "not mounted"
    if (sudo mount --read-only --types ntfs -o uid=$myUserName $line /tmp/wintest); then
          echo "mount in success."
          if [ -e "/tmp/wintest/Windows/explorer.exe" ]; then
                echo $line | cut -c 1-8 >> /tmp/win_devices
          fi
          # Need to sleep before unmount for some computers.
          sleep 1s
          sudo umount /tmp/wintest
        fi
  fi
done

# Output command to desktop
echo "Creating command shortcut at desktop  ..."
sort /tmp/win_devices | uniq | while read line; do
safeDeviceName=$(echo $line | sed -e "s/\///g")
shortCutName="trial-win-"$safeDeviceName".exe"
  echo "\
[Desktop Entry]\n\
Type=Application\n\
Name="$shortCutName"\n\
Exec=/usr/local/bin/winwin-launch.sh "$line"\n\
Terminal=true\n\
StartupNotify=false" > ~/Desktop/$shortCutName".desktop"
chmod +x ~/Desktop/$shortCutName".desktop"
done

# Just to keep displaying
echo "Success!!"
echo "Press any key to finish."
read hoge

