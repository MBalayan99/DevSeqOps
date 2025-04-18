#!/bin/bash

# Update system and install dependencies
sudo apt update
sudo apt install openvpn easy-rsa expect ufw -y

# Set up Easy-RSA and OpenVPN configurations
export EASYRSA_BATCH=1
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Initialize PKI and generate keys and certificates
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret ta.key
./easyrsa gen-crl

# Call the expect script to handle password input for client certificate generation
expect ~/gen_pass.exp

# Sign the client certificate
./easyrsa sign-req client developer1

# Set up server.conf and copy the necessary certificates and keys
sudo cp ~/openvpn-ca/pki/ca.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/issued/server.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/private/server.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/dh.pem /etc/openvpn/
sudo cp ~/openvpn-ca/ta.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/crl.pem /etc/openvpn/

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure UFW firewall
sudo ufw allow 1194/udp   # Allow OpenVPN port
sudo ufw allow 22/tcp     # Allow SSH
sudo ufw allow OpenSSH    # Ensure OpenSSH is allowed for remote access

# Modify UFW to allow packet forwarding by changing the policy
sudo sed -i 's/#DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw

# Edit UFW rules to NAT the traffic (modify before.rules)
sudo sed -i '/*nat/i -A POSTROUTING -s 10.8.0.0/8 -o ens4 -j MASQUERADE' /etc/ufw/before.rules

# Reload UFW to apply changes
sudo ufw reload

# Start OpenVPN service
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

