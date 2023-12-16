#!/bin/bash

wget https://golang.org/dl/go1.15.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.15.2.linux-amd64.tar.gz
echo "PATH=$PATH:/usr/local/go/bin" >> /etc/environment
source /etc/environment

wget https://github.com/kumina/openvpn_exporter/archive/v0.3.0.tar.gz
tar xzf v0.3.0.tar.gz
mv ~/main.go ~/openvpn_exporter-0.3.0/
cd openvpn_exporter-0.3.0/

/usr/local/go/bin/go build -o /usr/local/bin/openvpn_exporter main.go

cat > /etc/systemd/system/openvpn_exporter.service << 'EOF'
[Unit]
Description=Prometheus OpenVPN Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/openvpn_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now openvpn_exporter.service