#!/bin/bash
. /etc/utils/jlog.in

poweroff_num_check() {
	local limit=$1
	local file=/data/.offtime
	if [ -f "${file}" ];then
		local count=$(cat "${file}" | awk '/'$(date '+%F-%H')'/{print }' | wc -l)
	
		if [[ "${count}" -gt "${limit}" ]]; then
			jcrit_kvs "acc" "warning" "Start too much"
		fi
	fi
}

poweroff_check() {
	local file="/data/.off_reason"
	if [ -f "${file}" ];then
		rm -rf "${file}"
	else
		onofflog
		jwaring_kvs "acc" "warning" "last start is drop off"
	fi
}

main() {
	local limit=5
	[[ $1 ]] && limit="$1"
	poweroff_check
	poweroff_num_check "${limit}"
}

main "$@"