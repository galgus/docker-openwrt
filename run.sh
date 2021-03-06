#!/bin/bash
# set -x

function _usage() {
  echo "Could not find config file."
  echo "Usage: $0 [/path/to/openwrt.conf]"
  exit 1
}

SCRIPT_DIR=$(cd $(dirname $0) && pwd )
DEFAULT_CONFIG_FILE=$SCRIPT_DIR/$CONFIG_FILE
CONFIG_PATH_FILE=${1:-$DEFAULT_CONFIG_FILE}
source $CONFIG_PATH_FILE 2>/dev/null || { _usage; exit 1; }

# Funcion para desactivar NetworkManager en las interfaces Radio.
function _nmcli() {
  type nmcli >/dev/null 2>&1
  if [[ $? -eq 0 ]]; then
    echo "* setting interface '$WIFI_IFACE' to unmanaged"
        nmcli dev set $WIFI_IFACE managed no

    echo "* setting interface '$WIFI_IFACE_1' to unmanaged"
        nmcli dev set $WIFI_IFACE_1 managed no

    nmcli radio wifi on
  fi
}

function _get_phy_from_dev() {
  if [[ -f /sys/class/net/$WIFI_IFACE/phy80211/name ]]; then
    WIFI_PHY=$(cat /sys/class/net/$WIFI_IFACE/phy80211/name 2>/dev/null)
    echo "* got '$WIFI_PHY' for device '$WIFI_IFACE'"
  else
    echo "$WIFI_IFACE is not a valid phy80211 device"
    exit 1
  fi

  if [[ -f /sys/class/net/$WIFI_IFACE_1/phy80211/name ]]; then
    WIFI_PHY_1=$(cat /sys/class/net/$WIFI_IFACE_1/phy80211/name 2>/dev/null)
    echo "* got '$WIFI_PHY_1' for device '$WIFI_IFACE_1'"
  else
    echo "$WIFI_IFACE_1 is not a valid phy80211 device"
    exit 1
  fi
}

# envsubst sustituye "file.tpl" en "file"
function _gen_config() {
  echo "* generating network config"
  set -a
  source $CONFIG_PATH_FILE
  _get_phy_from_dev
  for file in etc/config/*.tpl; do
    envsubst <${file} >${file%.tpl}
    docker cp ${file%.tpl} $CONTAINER:/${file%.tpl}
  done
  for file in etc/aoifes/*.tpl; do
    envsubst <${file} >${file%.tpl}
    docker cp ${file%.tpl} $CONTAINER:/${file%.tpl}
  done
  set +a
}

function _init_network() {
  echo "* setting up docker network"
  docker network create --driver macvlan \
    -o parent=$LAN_PARENT \
    --subnet $LAN_SUBNET \
    $LAN_NAME || exit 1

  docker network create --driver macvlan \
    -o parent=$WAN_PARENT \
    $WAN_NAME || exit 1
}

function _create_or_start_container() {
  docker inspect $BUILD_TAG >/dev/null 2>&1 || { echo "no image '$BUILD_TAG' found, did you forget to run 'make build'?"; exit 1; }

  if docker inspect $CONTAINER >/dev/null 2>&1; then
    echo "* starting container '$CONTAINER'"
    docker start $CONTAINER
  else
    if [ ${CONFIG_FILE} == "openwrt.conf" ]; then
        _init_network
    fi

    echo "* creating container $CONTAINER"
    docker create \
      --network $LAN_NAME \
      --cap-add NET_ADMIN \
      --cap-add NET_RAW \
      --hostname openwrt \
      --dns 8.8.8.8 \
      --ip $LAN_ADDR \
      --sysctl net.netfilter.nf_conntrack_acct=1 \
      --sysctl net.ipv6.conf.all.disable_ipv6=0 \
      --sysctl net.ipv6.conf.all.forwarding=1 \
      --name $CONTAINER $BUILD_TAG >/dev/null
    docker network connect $WAN_NAME $CONTAINER

    _gen_config
    docker start $CONTAINER
  fi
}

function _set_hairpin() {
  echo -n "* set hairpin mode on interface '$1'"
  for i in {1..10}; do
    echo -n '.'
    sudo ip netns exec $CONTAINER ip link set $WIFI_IFACE type bridge_slave hairpin on 2>/dev/null && { echo 'ok'; break; }
    sudo ip netns exec $CONTAINER ip link set $WIFI_IFACE_1 type bridge_slave hairpin on 2>/dev/null && { echo 'ok'; break; }
    sleep 3
  done
  if [[ $i -ge 10 ]]; then
    echo -e "\ncouldn't set hairpin mode, wifi clients will probably be unable to talk to each other"
  fi
}

function _reload_fw() {
  echo "* reloading firewall rules"
  docker exec -i $CONTAINER sh -c '
    for iptables in iptables ip6tables; do
      for table in filter nat mangle; do
        $iptables -t $table -F
      done
    done
    /sbin/fw3 -q restart'
}

function _add_gw() {
  echo "* Adding default gateway to container"
  docker exec -i $CONTAINER sh -c '
        uci set network.lan.gateway=192.168.16.215 && uci commit && /etc/init.d/network restart
    '
}

function _cleanup() {
  echo -e "\n* cleaning up..."
  echo "* stopping container"
  docker stop $CONTAINER >/dev/null
  echo "* cleaning up netns symlink"
  sudo rm -rf /var/run/netns/$CONTAINER

  if [ ${CONFIG_FILE} == "openwrt.conf" ]; then
    echo "* removing host macvlan interface"
    sudo rmmod mac80211_hwsim
    sudo ip link del dev macvlan0
    docker network rm ${LAN_NAME}
    docker network rm ${WAN_NAME}
    sudo /root/./routing.sh -d
  fi
  echo -ne "* finished"
}

function main() {

  if [ ${CONFIG_FILE} == "openwrt.conf" ]; then
    sudo modprobe mac80211_hwsim radios=${N_HWSIM_RADIOS}
  fi

  test -z $WIFI_IFACE && _usage
  test -z $WIFI_IFACE_1 && _usage
  cd "${SCRIPT_DIR}"
  _get_phy_from_dev
  _nmcli
  _create_or_start_container

  echo "* moving device $WIFI_PHY to docker network namespace"
  pid=$(docker inspect -f '{{.State.Pid}}' $CONTAINER)
  sudo iw phy "$WIFI_PHY" set netns $pid

  echo "* moving device $WIFI_PHY_1 to docker network namespace"
  sudo iw phy "$WIFI_PHY_1" set netns $pid

  echo "* creating netns symlink '$CONTAINER'"
  sudo mkdir -p /var/run/netns
  sudo ln -sf /proc/$pid/ns/net /var/run/netns/$CONTAINER

  _set_hairpin $WIFI_IFACE
  _set_hairpin $WIFI_IFACE_1

  if [ ${CONFIG_FILE} == "openwrt.conf" ]; then
    echo "* setting up host macvlan interface"
    sudo ip link add macvlan0 link $LAN_PARENT type macvlan mode bridge
    sudo ip link set macvlan0 up
    sudo ip route add $LAN_SUBNET dev macvlan0

    #echo "* getting address via DHCP"
    sudo ip addr add 192.168.16.215/24 dev macvlan0
    #sudo dhcpcd -q macvlan0

    echo "* setting up host hwsim0 interface"
    sudo ip link set hwsim0 up

    sudo ./routing.sh -a 192.168.16.0/24 ens3
  fi

  _add_gw
  #_reload_fw

  echo "* ready"

}

main
trap "_cleanup" EXIT
tail --pid=$pid -f /dev/null
