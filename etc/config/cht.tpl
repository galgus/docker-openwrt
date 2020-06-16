#
# Copyright 2017 Galgus / AOIFES S.L. - http://www.galgus.net
#
# * CHT uci file

config cht 'config'
	option ka_send_interval '5'
	option port '40000'
	option bridge "${CHT_BRIDGE}"
	option enabled '1'

config lb 'lb'
	option lb_enabled '1'
	option lb_only_v '1'

config sr 'sr'
	option sr_enabled '1'
	option min_snr '20'
	option sr_only_v '0'
	option enable_sr_inact '0'
	option enable_sr_rssi '1'
	option max_inactive '120000'

config tc 'tc'
	option tc_enabled '1'
	option dl_sta_upper_limit '0'
	option dl_sta_lower_limit '0'
	option ul_sta_upper_limit '0'
	option rad_upper_limit    '0'
	option rad_lower_limit    '0'

config pre 'pre'
	option pre_enabled '1'
	option util_weight '0'
	option max_auth_attempts '3'
	option wl_timeout '10'
	option stas_5ghz_percent '80'
	option band_steering '0'
	option max_diff_probe_snr '10'

config mcast 'mcast'
	option mcast2ucast '0'

config wifi 'wifi'
	option enable_dfs '0'

config aca 'aca'
	option aca_enabled '1'

config proam 'proam'
	option proam_enabled '0'
	option proam_ssid 'Galgus'
	option proam_req_11k_interval '1000'
	option trans_threshold '-65'

config power 'power'
	option power_enabled '0'
	option decrease_margin '6'

config loc 'loc'
	option loc_module_enabled '1'
	option calc_interval '5'

config wips 'wips'
	option wips_module_enabled '0'