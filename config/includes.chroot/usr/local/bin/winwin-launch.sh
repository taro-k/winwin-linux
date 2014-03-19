#!/bin/sh

# Here, you can specify memory allocation (in MB)
# for Linux host (WinWin Linux).
# Otherwise, half of total memory is assigned.
# At least 512 is recommended, and more than 1024 seems better.
# e.g. memForLinux=1024
memForLinux=

memTotal=$(cat /proc/meminfo | grep MemTotal | tr -s ' ' | cut -d ' ' -f2)
tmp=`expr $memTotal \* 1024`
tmp=`expr $tmp / 1000`
memTotalM=`expr $tmp / 1000`
memTotalM2=`expr $memTotalM / 2`
memForWin=$memTotalM2

echo "The total memory in MB is" $memTotalM

if test -n "$memForLinux"; then
  echo "You specify" $memForLinux "MB for Linux."
  memForWin=`expr $memTotalM - $memForLinux`
else
  memForLinux=$memTotalM2
fi

if !(test $memForLinux -gt 240); then
  echo "Mem for Linux" $memForLinux "MB is too small! Press any key to exit."
  read hoge
  exit 1
fi

if !(test $memForWin -gt 240); then
  echo "Mem for Win" $memForWin "MB is too small! Press any key to exit."
  read hoge
  exit 1
fi

echo "Memory for Win is" $memForWin "MB."

driveKind=$(echo $1 | cut -c 6)
case $driveKind in
"s")
  echo "We asume your win device is SATA ..."
  driveOption="-device ahci,id=ahci0,bus=pci.0,addr=0x4 -drive file="$1",if=none,id=drive-sata0-0-0,format=raw,cache=none,aio=native -device ide-hd,bus=ahci0.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=1"
  ;;
"h")
  echo "We asume your win device is IDE ..."
  driveOption="-drive file="$1",if=none,id=drive-ide0-0-1,format=raw -device ide-hd,bus=ide.0,unit=1,drive=drive-ide0-0-1,id=ide0-0-1,bootindex=1"
  ;;
*)
  echo "Sorry, this version supports only SATA and IDE device ..."
  echo "Press any key to exit."
  read hoge
  exit 1
  ;;
esac

execWin="qemu-system-x86_64 "$driveOption" -cpu kvm64,+nx -enable-kvm -m "$memForWin" -snapshot"
echo $execWin
$execWin &

# Just to keep displaying
echo "Launched. Press any key to finish."
read hoge
