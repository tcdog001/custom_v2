#!/bin/bash

LOCAL_VCC_FILE=/tmp/vcc.log
LOCAL_VCC_MOVE_FILE=/root/vcc/vcc-quality-
LOCAL_VCC_INTVAL="0"

save_file() {
	local time="$@"

	time=$(get_vcc_time)
	[ -z ${time} ] && time=$(date '+%F-%H:%M:%S')

	[[ ${time} ]] && cp ${LOCAL_VCC_FILE} ${LOCAL_VCC_MOVE_FILE}-${time}
	if [ $? = 0 ]; then
		echo "$0: MOVE OK"
		> ${LOCAL_VCC_FILE}
	else
		echo "$0: MOVE NOK"
	fi
}

get_vcc_time() {
	local vcc_time=$(cat ${LOCAL_VCC_FILE} | awk -F '"' '{print $4}' | sed -n '$p')
	echo ${vcc_time}
}

do_service() {
	while :
	do
		save_file
		[[ "${LOCAL_VCC_INTVAL}" = "0" ]] && break
		sleep ${LOCAL_VCC_INTVAL}
	done
}

main() {
	[[ "$1" ]] && LOCAL_VCC_FILE="$1"
	[[ "$2" ]] && LOCAL_VCC_MOVE_FILE="$2"
	[[ "$3" ]] && LOCAL_VCC_INTVAL="$3"

	if [[ -f "${LOCAL_VCC_FILE}" ]]; then
		do_service
	else
		echo "$0: ${LOCAL_VCC_FILE} not found"
	fi	
}

main "$@"
