#!/bin/bash
eth=eth0
proto=udp
port=1194

# Настройка firewall
# Политика по умолчанию DROP
iptables -P INPUT DROP

iptables -P OUTPUT ACCEPT

iptables -P FORWARD DROP

# Разрешаем входящие соединения по ssh
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем исходящие соединения по ssh
iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем входящие соединения по vpn
iptables -A INPUT -i eth0 -p udp --dport 1194 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --sport 1194 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем исходящие соединения по vpn
iptables -A OUTPUT -o eth0 -p udp --dport 1194 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p udp --sport 1194 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем входящие соединения vpn exporter
iptables -A INPUT -i eth0 -p tcp --dport 9176 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 9176 -m state --state ESTABLISHED -j ACCEPT

# Разрешаем входящие соединения node exporter
iptables -A INPUT -i eth0 -p tcp --dport 9100 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 9100 -m state --state ESTABLISHED -j ACCEPT

# OpenVPN
iptables -A INPUT -i "$eth" -m state --state NEW -p "$proto" --dport "$port" -j ACCEPT
# Allow TUN interface connections to OpenVPN server
iptables -A INPUT -i tun+ -j ACCEPT
# Allow TUN interface connections to be forwarded through other interfaces
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o "$eth" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$eth" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
# NAT the vpn client traffic to the Internet
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$eth" -j MASQUERADE

# Сохраняем правила
mkdir /etc/iptables
chown -R yc-user /etc/iptables
iptables-save > /etc/iptables/rules.v4

# Добавляем в автозагрузку
echo "pre-up iptables-restore < /etc/iptables/rules.v4" >> /etc/network/interfaces

