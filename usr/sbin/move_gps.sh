#!/bin/bash

. /etc/utils/dir.in

LOCAL_GPS_PATH=/tmp/.log/gps
LOCAL_GPS_MOVE=gps-
LOCAL_GPS_FILE=/tmp/gps.log
LOCAL_GPS_INTVAL=0

do_move() {
	local time=$(get_gps_time)
	[[ -z ${time} ]] && time=$(date '+%F-%H:%M:%S')

	local gps_log=${LOCAL_GPS_MOVE}${time}

	[[ -z ${dir_tmp_log_gps} ]] && dir_tmp_log_gps=${LOCAL_GPS_PATH}
	gps_log=${dir_tmp_log_gps}/${gps_log}

	if [ ${time} ]; then
		[ ! -d ${dir_tmp_log_gps} ] && mkdir -p ${dir_tmp_log_gps}
		cp ${LOCAL_GPS_FILE} ${gps_log} 2> /dev/null
		if [ $? = 0 ];then
			> ${LOCAL_GPS_FILE}
		else
			echo "$0: MOVE NOK" $DEBUG_LOG_LOCAL
		fi
	fi
}

get_gps_time() {
	local time=$(cat ${LOCAL_GPS_FILE} | awk '{if(NR==1){print $1}}'| jq -j '.date')
	echo "${time}"
}

do_service() {
	while :
	do
		do_move
		[[ "${LOCAL_GPS_INTVAL}" = "0" ]] && break
		sleep ${LOCAL_GPS_INTVAL}
	done
}

#
# $1: output file, $2: input file
#
main() {
	[[ "$1" ]] && LOCAL_GPS_MOVE="$1"
	[[ "$2" ]] && LOCAL_GPS_FILE="$2"
	[[ "$3" ]] && LOCAL_GPS_INTVAL="$3"
	
	if [ -f $LOCAL_GPS_FILE ];then
		do_service
	else
		return 1
	fi
	return 0
}

main "$@"

