#!/bin/sh
basedir="`dirname "$0"`/.."
postmap="/usr/sbin/postmap"

if [ ! -z "$IP" ]; then
  ip=${IP#::ffff:}
  echo -e "$ip OK `date +%s`" | "$postmap" -ir "$basedir/db/allow_clients"
fi
exec "$@"
