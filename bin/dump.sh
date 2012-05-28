#!/bin/sh
basedir="`dirname "$0"`/.."
postmap="/usr/sbin/postmap"
"$postmap" -s hash:"$basedir/db/allow_clients"
