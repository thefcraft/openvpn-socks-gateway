#!/bin/sh
set -e

echo "[socks] waiting for tun0…"
until ip link show tun0 >/dev/null 2>&1; do
    sleep 1
done

echo "[socks] tun0 is up, starting dante"
exec sockd -f /etc/sockd.conf
