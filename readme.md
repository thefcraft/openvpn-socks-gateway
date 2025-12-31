# OpenVPN SOCKS5 Gateway

A lightweight, containerized OpenVPN to SOCKS5 proxy gateway that routes all your traffic through a VPN tunnel. Perfect for routing specific applications through a VPN without affecting your entire system.


**⚠️ Caution**
The Readme was AI-generated. (cause i hate writing by my own...)

## 🚀 Features

- **Isolated VPN Gateway**: Routes traffic through OpenVPN without affecting your host system
- **SOCKS5 Proxy**: Easy integration with any SOCKS5-compatible application
- **Podman/Docker Compatible**: Works with both container runtimes
- **Proton VPN Ready**: Optimized for Proton VPN (supports any OpenVPN provider)
- **Lightweight**: Minimal resource footprint

## 📋 Prerequisites

- Podman or Docker installed
- Podman Compose or Docker Compose
- An OpenVPN configuration file (`.ovpn`)
- VPN credentials

## 🔧 Setup

### 1. Clone the Repository

```bash
git clone https://github.com/thefcraft/openvpn-socks-gateway.git
cd openvpn-socks-gateway
```

### 2. Configure Your VPN

#### For Proton VPN Users:

1. Log in to your Proton VPN account
2. Navigate to [Downloads → OpenVPN configuration files](https://account.proton.me/u/0/vpn/OpenVpnIKEv2)
3. Download your preferred server configuration (`.ovpn` file)
4. Save it as `config/vpn.ovpn`
5. Create `config/auth.txt` with your Proton VPN credentials:
   ```
   your-protonvpn-username
   your-protonvpn-password
   ```

#### For Other VPN Providers:

1. Obtain your OpenVPN configuration file from your provider
2. Save it as `config/vpn.ovpn`
3. Create `config/auth.txt` with your credentials (one per line)

### 3. Start the Gateway

```bash
podman-compose up
```

Or with Docker:

```bash
docker-compose up
```

## 🎯 Usage

The SOCKS5 proxy will be available at `127.0.0.1:1080`

### Browser Configuration (Firefox)

1. Open Firefox Settings → Network Settings
2. Select "Manual proxy configuration"
3. Set SOCKS Host: `127.0.0.1`, Port: `1080`
4. Select "SOCKS v5"
5. **IMPORTANT**: Uncheck "Proxy DNS when using SOCKS v5"

### DNS Configuration (Recommended)

Since this gateway doesn't handle DNS resolution internally, configure your application to use a public DNS resolver:

- **Cloudflare DNS**: `1.1.1.1` / `1.0.0.1`
- **Google DNS**: `8.8.8.8` / `8.8.4.4`

**Firefox DNS Setup**:
1. Open **Firefox Settings**
2. Scroll down to **Network Settings**
3. Click **Settings…**
4. Under **DNS over HTTPS**, enable **Enable DNS over HTTPS**
5. From **Use Provider**, select **Cloudflare**
6. Set **Protection Level** to **Max Protection**
7. Click **OK**

This prevents DNS leaks and ensures your DNS queries don't use your system's default resolver.

### Command Line Usage

```bash
# Using curl
curl --socks5 127.0.0.1:1080 https://ifconfig.me

# Using wget
wget -e use_proxy=yes -e socks_proxy=127.0.0.1:1080 https://ifconfig.me
```

## 🔍 Verify Your Connection

Check if traffic is routed through the VPN:

```bash
# Without proxy (your real IP)
curl https://ifconfig.me

# With proxy (VPN IP)
curl --socks5 127.0.0.1:1080 https://ifconfig.me
```

## 📊 Monitoring

View logs:

```bash
# OpenVPN logs
podman logs -f vpn_gateway_openvpn

# SOCKS proxy logs
podman logs -f vpn_gateway_socksproxy
```

## 🛠️ Troubleshooting

### Connection Issues

1. Check if containers are running:
   ```bash
   podman ps
   ```

2. Verify VPN connection:
   ```bash
   podman exec vpn_gateway_openvpn ip addr show tun0
   ```

3. Test SOCKS proxy:
   ```bash
   curl --socks5 127.0.0.1:1080 https://ifconfig.me
   ```

## 📁 Project Structure

```
.
├── config/
│   ├── auth.txt          # VPN credentials (not tracked in git)
│   ├── danted.conf       # SOCKS5 proxy configuration
│   └── vpn.ovpn          # OpenVPN configuration (not tracked in git)
├── podman-compose.yml    # Container orchestration
├── .gitignore
└── README.md
```

## 🔒 Security Notes

- `auth.txt` and `vpn.ovpn` are excluded from git via `.gitignore`
- Never commit your credentials or VPN configuration files
- The proxy accepts connections from any IP by default - restrict in `danted.conf` if needed
- Consider using firewall rules to limit access to port 1080

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - feel free to use this project however you'd like.

## 🙏 Acknowledgments

- [kylemanna/openvpn](https://hub.docker.com/r/kylemanna/openvpn) - OpenVPN Docker image
- [wernight/dante](https://hub.docker.com/r/wernight/dante) - Dante SOCKS server image
- [Proton VPN](https://protonvpn.com) - Privacy-focused VPN service

## 💡 Use Cases

- Route specific applications through VPN
- Development and testing with different IP locations
- Privacy-focused browsing without full system VPN
- Bypassing geo-restrictions for specific applications
- Running multiple VPN connections simultaneously

---

**⚠️ Disclaimer**: Use this tool responsibly and in accordance with your VPN provider's terms of service and local laws.