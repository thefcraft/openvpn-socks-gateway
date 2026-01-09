# OpenVPN SOCKS5 Gateway

A lightweight, high-security OpenVPN to SOCKS5 gateway. It uses a strict "Fail-Closed" killswitch and DNS isolation to ensure your real IP and DNS queries never leak, even if the VPN connection drops.

**Note**
The Readme was AI-generated. (cause i hate writing by my own...)

## 🛡️ Security Features

- **Strict Killswitch**: Uses `iptables` to drop all traffic by default. Only the encrypted VPN tunnel and the initial handshake are whitelisted.
- **DNS Leak Protection**:
    - **Pre-Resolution**: Resolves the VPN server IP *before* locking down the firewall, allowing for a total block of port 53 (DNS) on your local network.
    - **Forced DNS**: Overwrites container DNS with Cloudflare (or your choice) to ignore ISP-injected DNS.
- **Dynamic Whitelisting**: Automatically detects your VPN server's IP from your `.ovpn` file to create a surgical firewall opening.
- **Container Isolation**: Shares the network stack between the VPN and SOCKS proxy, ensuring the proxy has no physical path to the internet except through the tunnel.

## 📋 Prerequisites

- Podman (rootless supported) or Docker.
- Podman-compose or Docker-compose.
- An OpenVPN configuration file (`.ovpn`) and [credentials](/config/auth.txt.example).

## 🔧 Setup

### 1. Repository Structure
Ensure your directory looks like this:
```text
.
├── config/
│   ├── auth.txt          # VPN Username (line 1) and Password (line 2)
│   ├── danted.conf       # SOCKS5 proxy config
│   └── vpn.ovpn          # Your VPN provider's config file
├── scripts/
│   ├── start-openvpn.sh  # Firewall & VPN logic
│   └── start-dante.sh    # Proxy health-check & startup
├── .env                  # Environment variables
└── podman-compose.yml    # (Or docker-compose.yml)
```

### 2. Configuration
Create a `.env` file in the root directory:
```bash
DNS_PRIMARY=1.1.1.1
DNS_SECONDARY=1.0.0.1
SOCKS_BIND_HOST=127.0.0.1
SOCKS_BIND_PORT=1080
```

### 3. Start the Gateway
```bash
podman-compose up
```

## 🎯 Usage & DNS Leak Prevention

To ensure 100% protection, follow these steps:

### Browser (Firefox Recommended)
1.  Settings → Network Settings → **Settings...**
2.  Select **Manual proxy configuration**.
3.  SOCKS Host: `127.0.0.1` | Port: `1080` | **SOCKS v5**.
4.  **✅ CRITICAL**: Check the box **"Proxy DNS when using SOCKS v5"**. 
    *If you miss this, your browser will leak your DNS queries to your local ISP.*

### Command Line
Always use the `socks5h` protocol to ensure the DNS lookup happens inside the VPN:
```bash
curl --socks5-hostname 127.0.0.1:1080 https://ifconfig.me
```

## 🔍 How the Killswitch Works
1.  **Resolve**: The `start-openvpn.sh` script finds the IP of your VPN server.
2.  **Lockdown**: All inbound/outbound/forwarding traffic is set to `DROP`.
3.  **Whitelist**: Only traffic to the resolved VPN IP and the local loopback is allowed on the physical interface.
4.  **Tunnel**: All other traffic is forced through `tun0`. If `tun0` goes down, traffic simply stops (Fail-Closed).

## 📊 Monitoring
```bash
# Check VPN Status
podman logs -f vpn_gateway_openvpn

# Check if tunnel is active
podman exec vpn_gateway_openvpn ip addr show tun0
```

## 📄 License
MIT