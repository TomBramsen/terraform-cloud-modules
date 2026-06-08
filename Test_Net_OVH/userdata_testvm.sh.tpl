#!/bin/bash
echo "ubuntu:Kodeord1" | chpasswd

ovh_subnet="${ovh_subnet}"
azure_subnet="${azure_subnet}"
azure_ip="${azure_ip}"
azure_psk="${azure_psk}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y strongswan strongswan-pki

# OVH GRA9 tildeler public IP direkte på interfacet (ikke floating IP / NAT)
# Derfor bruges PUBLIC_IP både som left og leftid
PUBLIC_IP=$(curl -s https://4.icanhazip.com)

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

    # Public IP sidder direkte på interfacet — ingen NAT
    left=$PUBLIC_IP
    leftid=$PUBLIC_IP
    leftsubnet=$ovh_subnet

    # Azure side
    right=$azure_ip
    rightid=$azure_ip
    rightsubnet=$azure_subnet

    # Ingen forceencaps — public IP er direkte på VM, ingen NAT imellem
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256-modp2048!

    ikelifetime=28800s
    keylife=27000s

    dpddelay=15s
    dpdtimeout=45s
    dpdaction=restart
EOF

cat <<EOF > /etc/ipsec.secrets
$PUBLIC_IP $azure_ip : PSK "$azure_psk"
EOF

systemctl enable strongswan-starter
systemctl restart strongswan-starter
