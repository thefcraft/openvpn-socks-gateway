#!/bin/sh
set -e

DNS_PRIMARY="${DNS_PRIMARY:-1.1.1.1}"
DNS_SECONDARY="${DNS_SECONDARY:-1.0.0.1}"

echo "[vpn] starting OpenVPN gateway bootstrap"

# 1. Resolve VPN server IP BEFORE firewall lockdown
REMOTE_HOST="$(grep '^remote ' /vpn_config/vpn.ovpn | awk '{print $2}' | head -n 1)"

if [ -z "$REMOTE_HOST" ]; then
    echo "[vpn] ERROR: could not extract remote host from ovpn"
    exit 1
fi

echo "[vpn] resolving VPN server: $REMOTE_HOST"

REMOTE_IP="$(getent hosts "$REMOTE_HOST" | awk '{print $1}' | head -n 1)"

# Fallback: already an IP
if [ -z "$REMOTE_IP" ]; then
    REMOTE_IP="$REMOTE_HOST"
fi

echo "[vpn] VPN server IP resolved to: $REMOTE_IP"
echo "[vpn] applying firewall lockdown"

# 2. Strict killswitch
iptables -P INPUT DROP || true
iptables -P FORWARD DROP || true
iptables -P OUTPUT DROP || true

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT || true
iptables -A OUTPUT -o lo -j ACCEPT || true

# Allow established / related traffic
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
iptables -A INPUT  -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true

# 3. Whitelist VPN server on eth0
iptables -A OUTPUT -o eth0 -d "$REMOTE_IP" -j ACCEPT || true

# 4. Allow everything through tunnel
iptables -A OUTPUT -o tun+ -j ACCEPT || true
iptables -A INPUT  -i tun+ -j ACCEPT || true

# 5. Force DNS (prevents OpenVPN DNS shenanigans)
echo "[vpn] enforcing DNS"
echo "[vpn] using DNS: $DNS_PRIMARY, $DNS_SECONDARY"
{
    echo "nameserver $DNS_PRIMARY"
    echo "nameserver $DNS_SECONDARY"
} > /etc/resolv.conf

# 6. Start OpenVPN
echo "[vpn] launching OpenVPN"
exec openvpn \
    --config /vpn_config/vpn.ovpn \
    --auth-user-pass /vpn_config/auth.txt \
    --route-nopull \
    --route 0.0.0.0 0.0.0.0 vpn_gateway \
    --redirect-gateway def1 \
    --pull-filter ignore "dhcp-option DNS"
