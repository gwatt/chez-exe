#!/bin/bash
#
# Needed libs:
#   libuuid-devel zlib-devel
#
# This script assumes that a stable version of ChezScheme has been
# installed with the distro's package manager.

# Get ChezScheme's architecture.
arch=$(echo '(machine-type)' | scheme --quiet)
# Get ChezScheme's version.
version=$(scheme --version 2>&1)

# Generate the Makefile for generating the chez-exe binary and libraries.
./gen-config.ss --prefix /usr --scheme /usr/bin/scheme \
  --bootpath /usr/lib/csv$version/$arch -lz

# Compile chez-exe (a.k.a chez-compile-program).
make

# Print useful messages.
echo "[MESSAGE] sudo make install -> Install the program to /usr/bin"
echo "[MESSAGE] sudo make uninstall -> Remove the program from the system."
