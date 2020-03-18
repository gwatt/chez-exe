#!/bin/bash
#
# Needed libs:
#   libuuid-devel ncurses-devel

arch=ta6le
procs=5
instdirprefix=/usr/local

git submodule init
git submodule update

cd ChezScheme
./configure --disable-x11 --threads
make -j$procs
cd ..
scheme --script gen-config.ss --prefix "$instdirprefix" \
    --scheme "$(pwd)/ChezScheme/$arch/bin/scheme" \
    --bootpath "$(pwd)/ChezScheme/$arch/boot/$arch"
make -j$procs

echo "Installation prefix set to \"$instdirprefix\""
echo "Issue a 'sudo make install' to install the program."
echo "Issue a 'sudo make uninstall' to uninstall the program."
