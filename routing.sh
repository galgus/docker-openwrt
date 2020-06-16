#!/bin/bash

function deactive_routing {
	echo "Deteniendo el corta fuegos y permitiendo todo el trafico..."
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t mangle -F
	iptables -t mangle -X
	iptables -L -n
	echo "0" > /proc/sys/net/ipv4/ip_forward
}

# $1: IP LAN
# $2: interface which is connected to Internet
function active_routing {
	echo "1" > /proc/sys/net/ipv4/ip_forward
	iptables -A FORWARD -j ACCEPT
	iptables -t nat -A POSTROUTING -s ${1} -o ${2} -j MASQUERADE
}

function active_bridge {
  iptables -t nat -A POSTROUTING -o ${1} -j MASQUERADE
# iptables -A INPUT -s ${2} -i ${3} -j ACCEPT
  echo 1 > /proc/sys/net/ipv4/ip_forward
}

if [ "${1}" == "-a" ]; then
	if [ ${#} -eq 3 ]; then
		active_routing ${2} ${3}
	else
		echo "Usage: ${0} ${1} IP/Netmask Network_interface"
	fi
elif [ "${1}" == "-d" ]; then
	if [ ${#} -eq 1 ]; then
		deactive_routing
	else
		echo "Usage: ${0} ${1}"
	fi
elif [ "${1}" == "-b" ]; then
  if [ ${#} -eq 2 ]; then
		active_bridge ${2} ${3} ${4}
	else
		echo "Usage: ${0} ${1} Output_Network_Interface"
	fi
else
	echo "Usage: ${0} -a IP/Netmask Network_Interface"
	echo "       ${0} -b Output_Network_Interface"
	echo "       ${0} -d"
fi
