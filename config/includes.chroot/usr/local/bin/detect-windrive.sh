#!/bin/sh

# Load KVM module
sudo /sbin/modprobe kvm
if (cat /proc/cpuinfo | grep Intel); then
  if !(sudo /sbin/modprobe kvm_intel); then
    echo "Check Virtualization in BIOS. Press any key to exit."
    read hoge
    exit 1
  fi
elif (cat /proc/cpuinfo | grep AMD); then
  if !(sudo /sbin/modprobe kvm_amd); then
    echo "Check Virtualization in BIOS. Press any key to exit."
    read hoge
    exit 1
  fi
else
  echo "Error: Your CPU supports Virtualization? Press any key to exit."
  read hoge
  exit 1
fi

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
          sleep 2s
          sudo umount /tmp/wintest
        fi
  fi
done

# Output command to desktop
echo "Creating command shortcut at desktop  ..."
sort /tmp/win_devices | uniq | while read line; do
safeDeviceName=$(echo $line | sed -e "s/\///g")
shortCutName="Win-trial(snapshot)"$safeDeviceName".exe"
  echo "\
[Desktop Entry]\n\
Type=Application\n\
Name="$shortCutName"\n\
Exec=qemu-system-x86_64 -device ahci,id=ahci0,bus=pci.0,addr=0x4 -drive file="$line",if=none,id=drive-sata0-0-0,format=raw,cache=none,aio=native -device ide-hd,bus=ahci0.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=1 -cpu kvm64,+nx -enable-kvm -m 1536 -snapshot\n\
Terminal=false\n\
StartupNotify=false" > ~/Desktop/$shortCutName".desktop"
chmod +x ~/Desktop/$shortCutName".desktop"
done

# Just to keep displaying
echo "Success!!"
echo "Press any key to finish."
read hoge

