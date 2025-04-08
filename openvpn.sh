sudo apt update
sudo apt install openvpn easy-rsa -y

# set some needed variables like this export EASYRSA_BATCH=1

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

sudo nano /etc/openvpn/server.conf

# port 1194
# proto udp
# dev tun
# ca /etc/openvpn/pki/ca.crt
# cert /etc/openvpn/pki/issued/server.crt
# key /etc/openvpn/pki/private/server.key
# dh /etc/openvpn/pki/dh.pem
# auth SHA256
# tls-auth /etc/openvpn/ta.key 0
# cipher AES-256-CBC
# user nobody
# group nogroup
# persist-key
# persist-tun
# keepalive 10 120
# topology subnet
# server 10.8.0.0 255.255.255.0
# push "redirect-gateway def1 bypass-dhcp"
# push "dhcp-option DNS 8.8.8.8"
# push "dhcp-option DNS 8.8.4.4"
# status /var/log/openvpn-status.log
# log /var/log/openvpn.log
# verb 3
# crl-verify /etc/openvpn/pki/crl.pem


sudo cp ~/openvpn-ca/pki/ca.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/issued/server.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/private/server.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/dh.pem /etc/openvpn/
sudo cp ~/openvpn-ca/ta.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/crl.pem /etc/openvpn/


sudo nano /etc/sysctl.conf

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

sudo nano /etc/ufw/before.rules

# Add these lines before the filter line:

# *nat
# :POSTROUTING ACCEPT [0:0]
# -A POSTROUTING -s 10.8.0.0/8 -o ens4 -j MASQUERADE
# COMMIT
sudo nano /etc/default/ufw
#DEFAULT_FORWARD_POLICY="ACCEPT"
sudo ufw disable && sudo ufw enable # -y maybe

sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

sudo systemctl status openvpn@server # in addintion

#--------------Client part----------------------
nano developer1.ovpn

# client
# dev tun
# proto udp
# remote <YOUR_EXTERNAL_IP> 1194
# resolv-retry infinite
# nobind
# persist-key
# persist-tun
# remote-cert-tls server
# cipher AES-256-CBC
# auth SHA256
# key-direction 1
# verb 3

# <ca>
# # paste ca.crt
# </ca>
# <cert>
# # paste developer1.crt
# </cert>
# <key>
# # paste developer1.key
# </key>
# <tls-auth>
# # paste ta.key
# </tls-auth>


