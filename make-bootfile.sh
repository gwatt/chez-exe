#!/bin/sh

scheme="$1"
psboot="$2"
csboot="$3"

unset CHEZSCHEMELIBDIRS CHEZSCHEMELIBEXTS

exec "$scheme" -q -b "$psboot" -b "$csboot" << __EOF__
(make-boot-file "boot" '() "$psboot" "$csboot")
__EOF__
