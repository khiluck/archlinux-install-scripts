#!/bin/bash

cd /usr/src

git clone git://git.suckless.org/dwm
git clone git://git.suckless.org/st
git clone git://git.suckless.org/dmenu
git clone git://git.suckless.org/scroll
git clone git://git.suckless.org/slock

# replace config.h files in directories and compile it with
#
# sudo make clean install
#
#
