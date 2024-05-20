#!/bin/bash

set -eu

ax25_port=${1:?missing port} || exit 1

tmpfile=$(mktemp ax25ipdXXXXX)
trap 'rm -f $tmpfile' exit

ax25ipd -c "/etc/ax25/ax25ipd-${ax25_port}.conf" >"$tmpfile"
pty=$(tail -1 "$tmpfile")

ln -sf "$pty" "/run/radio/pty.${ax25_port}"
