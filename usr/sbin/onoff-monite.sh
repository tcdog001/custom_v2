#!/bin/bash


clean_off_time_file() {
	local on_time=$1
	local file=/data/.offtime
	if [ -f "${file}" ];then
		if [[ "${on_time}" -gt "3600" ]];then
		rm -rf ${file}
		fi
	fi
}


check_on_time() {
	local on_time=$1
	local limit=$2
	
	if [[ "${on_time}" -gt "limit" ]];then
		logger "online over 12 hours"
	fi
}

main() {
	local limit=$1
	local on_time=$(cat /proc/uptime | awk -F '.' '{print $1}')
	
	clean_off_time_file "${on_time}"
	check_on_time "${on_time}" "${limit}"
}

main "$@"