## CHT CONFIGURATION FILE ##

[CORE]
syslog-level=7
syslog-name-cht=cht
logmask=255
license-location=/etc/aoifes/cht_license
uniprocess=1
interface=eth0
cipher_active=1

[NET]
port=40000
bridge=${LAN_NAME}
encrypt=1
log_mask=255

[MCAST]
mcast2ucast=0
log_mask=255

[WIFI]
max_stas=0
db_file=/tmp/probe_db.db
db_clean_interval=300
max_age_entries=24
probe_max_age=60
probes_max_rate=100
max_probe_mem=4000
dont_disc_stas=0
enable_dfs=0
t_stainfo=5000
t_heartbeat=20000
log_mask=255
<WIFI-SUBSECTION>
type=0
path=/var/run/hostapd
tmp=/tmp

[TMON]
log_mask=255

[SWARM]
ka_send_interval=5
max_keep_alives_lost=6
mcastloop=0
node_type=0
tx_window_check=20
tx_window_size=30
log_mask=255
def_ip=224.0.2.1
<ZONE 1>
ip=224.0.2.2
type=2
#<ZONE 2>
#ip=224.0.2.3
#<ZONE 3>
#ip=225.0.0.37

[ATH10]
log_mask=7

[MAC11]
enable_offchan=0
offchan_interval=1
num_frames_sent=3
log_mask=255

[ROAM]
timeout=10
memory_time=300
max_attempts=3
consider_traffic=1
log_mask=255

[SCI]
socket_file=/tmp/cht
socket_event_file=/tmp/cht_events
log_file=/tmp/cht_sci.log
enable_log=1
log_mask=7

[MGR]
enable_cloud=1
rabbit_conn=${RABBIT_CONN}:5671
cafile=/etc/aoifes/cacert.pem
amqp_heartbeat=30
log_mask=255
send_crashes=0

[LB]
lb_module_enabled=1
lb_only_v=1
monitoring_interval=10
threshold1=450
threshold2=500
min_dest_rssi=-75
max_diff_rssi=10
max_sim_roams=10
guard_time=1
v_buffer=5
multi_dest=1
idle_time=60000
log_mask=7
#<CONF 1>
#ssid=SSID-LB
#lb_enabled=0
#<CONF 2>
#ssid=HOO
#lb_enabled=1

[WCHT]
ath9k_factor=1
sampling_interval=1
average_interval=10
sharing_interval=5
req_11k_interval=2000
log_mask=255

[SR]
sr_module_enabled=1
sr_only_v=0
monitoring_interval=10
min_diff_snr=20
max_nu=450
max_cf=450
enable_sr_nu=1
enable_sr_rssi=1
enable_sr_inact=0
max_inactive=120000
log_mask=7
#<CONF 1>
##ssid=SSID-SR
##sr_enabled=0
##<CONF 2>
##ssid=HOO
##sr_enabled=1

[TC]
dl_sta_upper_limit=0
dl_sta_lower_limit=0
ul_sta_upper_limit=0
rad_upper_limit=0
rad_lower_limit=0
log_mask=7

[PRE]
pre_module_enabled=1
monitoring_interval=100
max_auth_attempts=3
wl_timeout_probe=10
wl_timeout_auth=0
wl_time=30
use_probe_block_policies=1
use_auth_block=0
use_auth_mode_dont_respond=1
stas_5ghz_percent=80
band_steering_mode=0
max_diff_probe_snr=10
util_weight=0
open_policies_no_clusters=1
log_mask=7
#<CONF 1>
#ssid=SSID-PRE
#pre_enabled=0
#<CONF 2>
#ssid=HOO
#pre_enabled=1

[WVIC]
wvic_module_enabled=1
scan_rounds=2
weigh_policy=0
scan_period=300000
log_mask=255

[ACA]
aca_module_enabled=1
population_size=100
max_time=30
max_cx_points=1
cx_prob=60
mut_prob=90
num_migrants=4
dual_dfs_calc=0
num_objectives=2
dump_aca_info=0
dump_aca_info_path=/tmp
log_mask=255

[SYS]
log_mask=255

[NMAP2]
log_mask=7

[PROAM]
proam_module_enabled=0
log_mask=255
trans_threshold=-65
req_11k_interval=2000
path_learning=1
proam_ssid=Galgus
dump_proam_info=0
dump_proam_info_path=/tmp

[BRAIN]
log_mask=7

[POWER]
power_enabled=0
decrease_margin=6
log_mask=7
dump_power_info=0
dump_power_info_path=/tmp

[LOC]
loc_module_enabled=1
calc_interval=5
old_calc_weight=0.7
min_nodes_loc=3
log_mask=255
#<CONF 1>
#ssid=GALGUS
#loc_enabled=0

[WIPS]
wips_module_enabled=0
power_enabled=0
mit_power_timer=100000
mit_deauth_enabled=1
mit_deauth_timer=1000
mit_deauth_frames=5
enable_bssid_change=1
log_mask=255