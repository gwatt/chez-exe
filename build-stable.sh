#!/bin/bash
#
# Needed libs:
#   libuuid-devel zlib-devel
#
# This script assumes that a stable version of the ChezScheme has been installed
# with the package manager.

arch=ta6le
procs=5
version=9.5.2

./gen-config.ss --prefix /usr --scheme /usr/bin/scheme --bootpath /usr/lib/csv$version/$arch -lz
make -j$procs
echo "[MESSAGE] sudo make install -> Install the program to /usr/bin"
echo "[MESSAGE] sudo make uninstall -> Remove the program from the system."
