#!/bin/bash

. /etc/utils/dir.in
ERROR_NOSUPPORT="Not supported"

car_system_now=$(date '+%F-%H:%M:%S')

get_temp() {
    local string=$(temperature_show | awk '{print $3}')

    echo ${string}
}

get_cpu_use() {
    local cpuUse=$(top -n 1 |awk '{print $8}' |sed '1,4d' |awk '{sum += $1};END {print sum}')

    if [[ -z ${cpuUse} ]]; then
        cpuUse="0%"
    fi
    echo "${cpuUse}%"
}

get_memory_use() {
    local memorySize=$(free |awk -F ' ' '/Mem:/{print $2}')
    local memoryUse=$(free |awk -F ' ' '/Mem:/{print $3}')
    local memoryUsage1=$(awk 'BEGIN{printf "%.2f\n",'${memoryUse}'/'${memorySize}'*100}')
    local memoryUsage=$(echo ${memoryUsage1}%)

    if [[ -z ${memoryUsage} ]]; then
        memoryUsage="0%"
    fi
    echo ${memoryUsage}
}

get_ssd_Usage() {
    local ssdUsage=$(df -h /dev/sda1 |awk -F ' ' '{print $5}' |sed -n '$p')

    if [[ -z ${ssdUsage} ]]; then
        ssdUsage="0%"
    fi
    echo ${ssdUsage}
}

get_ssd_erasenum() {
    echo "${ERROR_NOSUPPORT}"
}

get_ssd_badnum() {
    echo "${ERROR_NOSUPPORT}"
}
#
# $1: string
# $2: path and filename
#
str_output() {
    local string="$1"
    local path="$2"

    echo ${string} > ${path}
}

get_ip() {
    local ip=$(ifconfig ppp0 | awk '/inet/{print $2}' | awk -F ':' '{print $2}')

    if [[ -z ${ip} ]]; then
        ip="0%"
    fi
    echo ${ip}
}

get_online_user() {
	echo "${ERROR_NOSUPPORT}"
}

get_today_user() {
	echo "${ERROR_NOSUPPORT}"
}

get_gps_antenna() {
	echo "${ERROR_NOSUPPORT}"
}

get_3g_status() {
	local status=$(/usr/sbin/get_sysinfo cellular1.status)
	case ${status} in
	0)
		status="online"
		;;
	1)
		status="offline"
		;;
	*)
		
		status="null"
		;;
	esac
	
    echo ${status}
}

#
# $1: key
# $2: value; shift 2
# $@: json string
#
add_json_string() {
    local key="$1"
    local value="$2"; shift 2
    local str_old="$@"
    local str_new="\"${key}\": \"${value}\""
    local str_entirety
    
    if [[ ${str_old} ]]; then
        str_entirety="${str_old}, ${str_new}"
    else
        str_entirety=${str_new}
    fi

    echo ${str_entirety}
}

#
# $@: json string
#
str_systemlog_ap() {
    local jsonstr="$@"
    # file_systemlog_ap from /etc/utils/dir.in
    local jsonap=$(cat ${file_systemlog_ap})
 
    [[ ${jsonap} ]] && jsonstr="${jsonstr}, ${jsonap}"
    [[ ${jsonstr} ]] && echo ${jsonstr}
}

str_systemlog_3g() {
    local jsonstr="$@"


	jsonstr=$(add_json_string "sim-iccid" "$(/usr/sbin/get_sysinfo cellular1.iccid)" "${jsonstr}")
	jsonstr=$(add_json_string "3g-status" "$(get_3g_status)" "${jsonstr}")
	jsonstr=$(add_json_string "3g_net" "$(/usr/sbin/get_sysinfo cellular1.carrier)" "${jsonstr}")
	jsonstr=$(add_json_string "3g_strong" "$(/usr/sbin/get_sysinfo cellular1.strength | sed -n '$p')" "${jsonstr}")
	

    [[ ${jsonstr} ]] && echo ${jsonstr}
}


#
# $@: json string
#
str_systemlog_md() {
    local jsonstr="$@"

    jsonstr=$(add_json_string "recordtime" "${car_system_now}" "${jsonstr}")
	jsonstr=$(add_json_string "internet_ip" "$(get_ip)" "${jsonstr}")
    jsonstr=$(add_json_string "process_num" "$(ps -w | wc -l)" "${jsonstr}")
	jsonstr=$(add_json_string "online_user" "$(get_online_user)" "${jsonstr}")
	jsonstr=$(add_json_string "today_user" "$(get_today_user)" "${jsonstr}")
	jsonstr=$(add_json_string "today_flow" "$(/usr/sbin/get_sysinfo cellular.flow)" "${jsonstr}")
    jsonstr=$(add_json_string "cpu_temp" "$(get_temp)" "${jsonstr}")
    jsonstr=$(add_json_string "cpu" "$(get_cpu_use)" "${jsonstr}")

    jsonstr=$(add_json_string "memory" "$(get_memory_use)" "${jsonstr}")
    jsonstr=$(add_json_string "disk_used" "$(get_ssd_Usage)" "${jsonstr}")
    jsonstr=$(add_json_string "disk_erased" "$(get_ssd_erasenum)" "${jsonstr}")
	jsonstr=$(add_json_string "disk_bad" "$(get_ssd_badnum)" "${jsonstr}")
	jsonstr=$(add_json_string "gps_satellite" "$(/usr/sbin/get_sysinfo gps.satellite)" "${jsonstr}")
	jsonstr=$(add_json_string "gps_antenna" "$(get_gps_antenna)" "${jsonstr}")
	
	

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

main() {
    # function getnow from /etc/utils/time.in
    local logname="car_system-${car_system_now}.log"
    local jsonstr=""

    jsonstr=$(str_systemlog_md ${jsonstr})
    #jsonstr=$(str_systemlog_ap ${jsonstr})
	jsonstr=$(str_systemlog_3g ${jsonstr})

    # dir_opt_log_dev_monitor from etc/utils/dir.in
    str_output "{ ${jsonstr} }" "${dir_tmp_log_dev_monitor}/${logname}"
}

main "$@"
