#!/bin/sh
basedir="`dirname "$0"`/.."
postmap="/usr/sbin/postmap"
lifetime="${1-600}"
expire=$((`date +%s` - $lifetime))

"$postmap" -s hash:"$basedir/db/allow_clients" |
while read ip status mtime; do
  test $expire -lt $mtime 2>/dev/null || echo $ip
done |
"$postmap" -d- "$basedir/db/allow_clients"

exit 0
