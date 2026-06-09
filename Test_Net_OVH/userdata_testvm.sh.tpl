#!/bin/bash
echo "ubuntu:Kodeord1" | chpasswd

ovh_subnet="${ovh_subnet}"
azure_subnet="${azure_subnet}"
azure_ip="${azure_ip}"
azure_psk="${azure_psk}"

mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dns.conf << EOF
[Resolve]
DNS=${dns_servers}
EOF
systemctl restart systemd-resolved

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y strongswan strongswan-pki

# The floating IP is NAT'd by OVH infrastructure — the VM interface only has the
# private IP. curl returns the floating IP that Azure sees us from.
FLOATING_IP=$(curl -s https://4.icanhazip.com)

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

cat <<EOF > /etc/ipsec.conf
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=yes

conn azure-s2s
    authby=secret
    auto=start
    type=tunnel
    keyexchange=ikev2

    # left is the VM's private interface — leftid is the floating IP Azure connects to
    left=%defaultroute
    leftid=$FLOATING_IP
    leftsubnet=$ovh_subnet

    # Tvungen UDP-indkapsling pga. NAT (floating IP)
    forceencaps=yes

    # Azure side
    right=$azure_ip
    rightid=$azure_ip
    rightsubnet=$azure_subnet

    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!

    ikelifetime=28800s
    keylife=27000s

    dpddelay=15s
    dpdtimeout=45s
    dpdaction=restart
EOF

cat <<EOF > /etc/ipsec.secrets
$FLOATING_IP $azure_ip : PSK "$azure_psk"
EOF

systemctl enable strongswan-starter
systemctl restart strongswan-starter
