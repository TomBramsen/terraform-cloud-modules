#!/bin/bash
# ==============================================================================
# Client VM — router Azure-trafik via VPN VM
# ==============================================================================

echo "ubuntu:Kodeord1" | chpasswd

# Tilføj rute til Azure subnet via VPN VM's private IP (med det samme)
ip route replace ${azure_subnet} via ${vpn_private_ip}

# Gør ruten persistent på tværs af reboots via systemd
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
