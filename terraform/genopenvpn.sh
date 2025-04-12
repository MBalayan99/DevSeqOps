#!/bin/bash
set -euo pipefail

# Install OpenVPN and Easy-RSA
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y openvpn easy-rsa ufw

# Set up Easy-RSA
EASYRSA_DIR=/etc/openvpn/easy-rsa
make-cadir $EASYRSA_DIR
cd $EASYRSA_DIR
export EASYRSA_BATCH=1

./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret ta.key
./easyrsa gen-crl

./easyrsa gen-req developer1 
./easyrsa sign-req client developer1

# Move files to /etc/openvpn
cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/
cp ta.key /etc/openvpn/
cp pki/crl.pem /etc/openvpn/

# Write OpenVPN server configuration
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
auth SHA256
tls-auth /etc/openvpn/ta.key 0
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
crl-verify /etc/openvpn/crl.pem
EOF

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Configure UFW
ufw allow 1194/udp
ufw allow OpenSSH

# Modify UFW before.rules
sed -i '/^*filter/i \
*nat\n\
:POSTROUTING ACCEPT [0:0]\n\
-A POSTROUTING -s 10.8.0.0/8 -o ens4 -j MASQUERADE\n\
COMMIT\n' /etc/ufw/before.rules

# Set forwarding policy
sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

ufw disable
ufw --force enable

# Enable and start OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server
