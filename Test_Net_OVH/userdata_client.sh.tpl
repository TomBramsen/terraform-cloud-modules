#!/bin/bash
# ==============================================================================
# Client VM — router Azure-trafik via VPN VM
# ==============================================================================

echo "ubuntu:Kodeord1" | chpasswd

mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dns.conf << EOF
[Resolve]
DNS=${dns_servers}
EOF
systemctl restart systemd-resolved

# Add route to Azure subnet via VPN VM's private IP (immediately)
ip route replace ${azure_subnet} via ${vpn_private_ip}

# Make the route persistent across reboots via systemd
cat > /etc/systemd/system/azure-route.service << 'EOF'
[Unit]
Description=Static route to Azure via VPN VM
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ip route replace ${azure_subnet} via ${vpn_private_ip}
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable azure-route
systemctl start azure-route
