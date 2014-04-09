#!/bin/sh

# Here, you can specify memory allocation (in MB)
# for Linux host (WinWin Linux).
# Otherwise, half of total memory is assigned.
# At least 512 is recommended, and more than 1024 seems better.
# e.g. memForLinux=1024
# Now it is an environment variable
#memForLinux=

vboxmanage setproperty machinefolder ~/winwin-vm
vmDir="winwin-vm"
#vmDir="VirtualBox VMs"

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
          if (sudo find /tmp/wintest/ -maxdepth 2 -iname explorer.exe | grep --ignore-case windows); then
                echo $line": Win system is found!"
                echo $line | cut -c 6- >> /tmp/win_devices
          fi
          # Need to sleep before unmount for some computers.
          sleep 1s
          sudo umount /tmp/wintest
        fi
  fi
done

# Create VM directory
echo "Creating folder "$vmDir"  ..."
if (find ~ -maxdepth 1 -type d -name "$vmDir" | grep "$vmDir"); then
  echo "  We already have."
else
  mkdir ~/"$vmDir"
fi

# Set memory for VM
# Detect architecture
thisArch=$(dpkg --print-architecture)
# Find current total memory
memTotal=$(cat /proc/meminfo | grep MemTotal | tr -s ' ' | cut -d ' ' -f2)
tmp=`expr $memTotal \* 1024`
tmp=`expr $tmp / 1000`
memTotalM=`expr $tmp / 1000`
memTotalM2=`expr $memTotalM / 2`
memForWin=$memTotalM2
#
echo "The total memory is" $memTotalM "MB."
#
if test -n "$memForLinux"; then
  echo "You specify" $memForLinux "MB for Linux."
  memForWin=`expr $memTotalM - $memForLinux`
else
  memForLinux=$memTotalM2
fi
if !(test $memForLinux -gt 240); then
  echo "ERROR: Mem for Linux" $memForLinux "MB is too small! Press any key to exit."
  read hoge
  exit 1
fi
if !(test $memForWin -gt 240); then
  echo "ERROR: Mem for Win" $memForWin "MB is too small! Press any key to exit."
  read hoge
  exit 1
fi
if (test $memForWin -gt 2047 && $thisArch != "amd64" ); then
  memForWin=2047
  echo "Mem for Win is capped at " $memForWin "MB."
fi
echo "Memory for Win is" $memForWin "MB."

# Create config files
echo "Creating directory for config files ..."
sort /tmp/win_devices | while read devName; do
  devName0=$(echo $devName | sed -e "s/[0-9]//g")
  devPartition=$(echo $devName | sed -e "s/[^0-9]//g")

  # Detect IDE or SATA or ...

# Followings is commendeted out at this moment,
# because XP I tested doesn't work
# with SATA and works with IDE even if original XP works on SATA.
# by Taro Konda
#  driveKind=$(echo $devName | cut -c 1-2)
#  case $driveKind in
#  "sd")
#    echo "We asume your win device is SATA ..."
#    ;;
#  "hd")
#    echo "We asume your win device is IDE ..."
#    ;;
#  *)
#    echo "WARNING: This version supports only SATA and IDE device ..."
#    echo "ERROR: This version supports only SATA and IDE device ..."
#    echo "Press any key to exit."
#    read hoge
#    exit 1
#    ;;
#  esac

  vmdkFile=$devName".vmdk"
  if (test -e ~/"$vmDir"/"$vmdkFile"); then
    echo "  ERROR: vmdk file already exists!"
	echo "Launch Virtualbox from menu by yourself. Press any key to exit."
    read hoge
	exit 1
  else
    echo "  Creating vmdk file ..."
  # Create VMDK file
    vboxmanage internalcommands createrawvmdk -rawdisk /dev/$devName0 -filename ~/$vmDir/$vmdkFile -partitions $devPartition
    #vmdkUuid=$(grep uuid.image ~/"$vmDir"/"$vmdkFile" | cut -c 16-)
  # Create VM
    vboxmanage createvm --name $devName --register
  # Setting up VM
    vboxmanage modifyvm $devName --ostype WindowsXP --memory $memForWin --vram 16 --ioapic on --pae on --usb on --nic1 nat
  # Setting up storage
  # Here is only IDE at this moment, because XP I tested doesn't work
  # with SATA and works with IDE even if original XP works on SATA.
  # by Taro Konda
	vboxmanage modifyhd ~/"$vmDir"/"$vmdkFile" --type immutable
    vboxmanage storagectl $devName --name IDE --add ide --controller ICH6 --bootable on
    vboxmanage storageattach $devName --storagectl IDE --type hdd --medium ~/"$vmDir"/"$vmdkFile" --port 0 --device 0
  fi

done

#if (test $thisArch = "amd64" ); then
#  echo "WARNING: This version doesn't support 64bit OS ..."
#  echo "ERROR: This version doesn't support 64bit OS ..."
#  echo "Press any key to exit."
#  read hoge
#  exit 1
#fi
echo "WARNING: DO NOT CLOSE this window until Win finishes."
nohup virtualbox &
read hoge
