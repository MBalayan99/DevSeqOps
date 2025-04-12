#!/bin/bash

set -e

# Variables
VPN_USER="developer1"
VPN_SERVER_NAME="server"
VPN_SUBNET="10.8.0.0"
VPN_SUBNET_MASK="255.255.255.0"
EXTERNAL_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")
IFACE="ens4" # May vary (eth0 on some)

# Update & install
apt-get update
apt-get install -y openvpn easy-rsa ufw curl

# Easy-RSA setup
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
echo -ne '\n' | ./easyrsa build-ca nopass
./easyrsa gen-req $VPN_SERVER_NAME nopass
./easyrsa sign-req server $VPN_SERVER_NAME <<< "yes"
./easyrsa gen-dh
openvpn --genkey --secret ta.key
./easyrsa gen-req $VPN_USER nopass
./easyrsa sign-req client $VPN_USER <<< "yes"
./easyrsa gen-crl

# Copy server files
cp pki/ca.crt /etc/openvpn/
cp pki/issued/$VPN_SERVER_NAME.crt /etc/openvpn/server.crt
cp pki/private/$VPN_SERVER_NAME.key /etc/openvpn/server.key
cp pki/dh.pem /etc/openvpn/
cp ta.key /etc/openvpn/
cp pki/crl.pem /etc/openvpn/

# Create server.conf
cat > /etc/openvpn/server.conf <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA256
tls-auth ta.key 0
topology subnet
server $VPN_SUBNET $VPN_SUBNET_MASK
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
crl-verify crl.pem
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# UFW Rules
ufw allow 1194/udp
ufw allow OpenSSH
sed -i "s/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw

cat > /etc/ufw/before.rules <<EOF
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s $VPN_SUBNET/$VPN_SUBNET_MASK -o $IFACE -j MASQUERADE
COMMIT
EOF

ufw --force enable

# Enable and start OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server

# Create client .ovpn config
mkdir -p /etc/openvpn/client-configs
cat > /etc/openvpn/client-configs/$VPN_USER.ovpn <<EOF
client
dev tun
proto udp
remote $EXTERNAL_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
key-direction 1
verb 3

<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
<cert>
$(cat pki/issued/$VPN_USER.crt)
</cert>
<key>
$(cat pki/private/$VPN_USER.key)
</key>
<tls-auth>
$(cat /etc/openvpn/ta.key)
</tls-auth>
EOF

echo "✅ VPN setup complete. .ovpn file is at /etc/openvpn/client-configs/$VPN_USER.ovpn"
