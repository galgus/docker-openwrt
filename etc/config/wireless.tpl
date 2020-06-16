config 'wifi-device'    'radio0'
    option 'type'       'mac80211'
    option 'phy'        "${WIFI_PHY}"
    option 'hwmode'     "${WIFI_HW_MODE}"
    option 'htmode'     "${WIFI_HT_MODE}"
    option 'channel'    "${WIFI_CHANNEL}"
    option path 'virtual/mac80211_hwsim/${VIRT_HWSIM_WLAN2}'

config 'wifi-device'    'radio1'
    option 'type'       'mac80211'
    option 'phy'        "${WIFI_PHY_1}"
    option 'hwmode'     "${WIFI_HW_MODE_1}"
    option 'htmode'     "${WIFI_HT_MODE_1}"
    option 'channel'    "${WIFI_CHANNEL_1}"
    option path 'virtual/mac80211_hwsim/${VIRT_HWSIM_WLAN3}'

config 'wifi-iface'     "${WIFI_IFACE}"
    option 'device'     'radio0'
    option 'network'    'lan'
    option 'mode'       'ap'
    option 'ifname'     "${WIFI_IFACE}"
    option 'ssid'       "${WIFI_SSID}"
    option 'encryption' "${WIFI_ENCRYPTION}"
    option 'key'        "${WIFI_KEY}"
    option 'disassoc_low_ack' '0'

config 'wifi-iface'     "${WIFI_IFACE_1}"
    option 'device'     'radio1'
    option 'network'    'lan'
    option 'mode'       'ap'
    option 'ifname'     "${WIFI_IFACE_1}"
    option 'ssid'       "${WIFI_SSID_1}"
    option 'encryption' "${WIFI_ENCRYPTION_1}"
    option 'key'        "${WIFI_KEY_1}"
    option 'disassoc_low_ack' '0'