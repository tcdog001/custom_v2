#!/bin/bash

. /etc/utils/dir.in
. /etc/utils/jlog.in

LOCAL_VCC_FILE=/tmp/vcc.log
LOCAL_VCC_PATH=/opt/log/vcc
LOCAL_VCC_MOVE_FILE=vcc-quality-
LOCAL_VCC_INTVAL=0

save_file() {
	local time=$(get_vcc_time)
	[ -z ${time} ] && time=$(date '+%F-%H:%M:%S')

	local vcc_log=${LOCAL_VCC_MOVE_FILE}${time}
	[[ -z ${dir_opt_log_vcc} ]] && dir_opt_log_vcc=${LOCAL_VCC_PATH} 
	vcc_log=${dir_opt_log_vcc}/${vcc_log}
	
	[ ! -d ${dir_opt_log_vcc} ] && mkdir -p ${dir_opt_log_vcc}
	cp ${LOCAL_VCC_FILE} ${vcc_log} 2> /dev/null
	if [ $? = 0 ]; then
		> ${LOCAL_VCC_FILE}
	else
		jdebug_error "$0: MOVE NOK"
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
		jdebug_error "$0: ${LOCAL_VCC_FILE} not found"
	fi	
}

main "$@"
