#!/bin/bash

LOCAL_GPS_MOVE=/tmp/log/gps/gps-
LOCAL_GPS_FILE=/tmp/gps.log
LOCAL_GPS_TIME=""
LOCAL_GPS_INTVAL=0

do_move() {
	local time=${LOCAL_GPS_TIME}
	local LOCAL_TMP_FILE=${LOCAL_GPS_MOVE}${time}

	if [ ${time} ]; then
		cp ${LOCAL_GPS_FILE} ${LOCAL_TMP_FILE} 2> /dev/null
		if [ $? = 0 ];then
			echo "$0: MOVE OK" $DEBUG_LOG_LOCAL
			> ${LOCAL_GPS_FILE}
		else
			echo "$0: MOVE NOK" $DEBUG_LOG_LOCAL
		fi
	fi
}

get_gps_time() {
	LOCAL_GPS_TIME=$(/bin/cat $LOCAL_GPS_FILE | awk '{if(NR==1){print $1}}'| jq -j '.date')
	echo "$0: ${LOCAL_GPS_TIME}" $DEBUG_LOG_LOCAL
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
		get_gps_time
		[[ -z ${LOCAL_GPS_TIME} ]] && return 1
		do_service
	else
		return 1
	fi
	return 0
}

main "$@"

