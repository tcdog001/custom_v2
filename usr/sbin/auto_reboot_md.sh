#!/bin/sh
. /usr/sbin/common_opera.in
. /etc/utils/dir.in
#
# Record the timeout log
#
write_log() {
		local offtime=""
		if [[ ${reason} == "drop_off" ]];then
			offtime="NULL"
		else
			offtime=$(get_now_time)
		fi
		local ontime_file=/tmp/.startup
		local ontime=$(cat ${ontime_file} |sed -n '$p' 2>/dev/null)
#		local log_path=/data
		local log_file=on-off-${offtime}.log
		local reason=$1

		printf '{"ontime":"%s", "offtime":"%s", "reason":"%s"}\n'	\
				"${ontime}"		\
				"${offtime}"	\
				"${reason}"		> ${dir_opt_log_onoff}/${log_file}
}
#
# write the log, close process, sync and sysreboot
#
do_reboot() {
		sysled main off
		write_log "timeout"
		sync
		sleep 3
		sysreboot
}

main() {
		# From power began to wait X hours
		local reb_interval=$1
		if [[ -z ${reb_interval} ]];then
			reb_interval=12h
		fi
		sleep ${reb_interval}; local ret=$?
		if [[ ${ret} -eq 0 ]];then
			do_reboot
		fi
}

main "$@"
