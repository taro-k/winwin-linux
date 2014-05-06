* For developer

Source tree of WinWin Linux has two separated directories:
1. winwinlinux: OS itself
2. winwintools: tool programs for winwin linux OS

** Prepare stable Debian for builds
WinWin Linux is greatly based on Debian live system and Debian packaging system.
If you wish to build WinWin Linux OS and/or winwin-tools, first try to prepare
the latest Debian stable version. Here, Wheezy is assumed.

See more detail about Debian live system in
http://live.debian.net/

** How to build winwinlinux

Install a tool for the build
$ sudo apt-get install live-build

Clone the git repository:
$ git clone git@github.com:taro-k/winwin-linux.git

The working directory is winwin-linux/winwinlinux
$ cd winwin-linux/winwinlinux

If you don't use apt-cacher-ng, change lb_build_mirror_* in auto/config.
See the next sub section for the detail of apt-cacher-ng.

Set config and build:
$ sh auto/config
$ sudo lb build
*.iso like binary.hybrid.iso is the iso image to burn.

clean up before re-build:
$ sudo lb clean

The package of winwin-tools is to be included in WinWinLinux OS.

** Use apt-cacher-ng
We strongly recommend to use apt-cacher-ng to cache apt files.
$ sudo apt-get install apt-cacher-ng
$ sudo aptitude update

* How to build winwinlinux
Coming soon.
