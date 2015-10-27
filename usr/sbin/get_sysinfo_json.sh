#!/bin/bash

#
# $1: key
# $2: type e.g. 0:string, 1:int
# $3: value
#
make_json_string() {
    local key=$1
    local type=$2
    local value=$3
    local str_new=""
   
    if [[ -z "${value}" || "null" = "${value}" || "none" = "${value}" ]]; then
		str_new=""
	elif [[ ${type} -eq 1 ]]; then
    	str_new="{\"${key}\":${value}}"
	else
    	str_new="{\"${key}\":\"${value}\"}"
    fi

    echo ${str_new}
}

#
# $1: str_new; shift 1
# $2: str_old
# e.g. echo "{\"a\":1,\"b\":2}" | jq -c -j ". * {\"b\":3,\"c\":4}"
#
add_json_string() {
    local key=$1
    local type=$2
    local value=$3; shift 3
    local str_old=$@
    local str_new=""
    local str_entirety=""
   
	str_new=$(make_json_string "${key}" "${type}" "${value}")
	
    if [[ -z "${str_new}" ]]; then
        str_entirety=${str_old}
    elif [[ -z "${str_old}" ]]; then
    	str_entirety=${str_new}
    else
	    str_entirety=$(echo ${str_old} | jq -c -j ". * ${str_new}")
    fi

    echo ${str_entirety}
}

# SwVer WebFrameVer WebRsrcVer CfgVer LastLoginTime LastLoginLat LastLoginLng
get_json_md_funcinfo() {
    local jsonstr=$@
    
    jsonstr=$(add_json_string "SwVer" "0" "$(get_sysinfo sw.version)" "${jsonstr}")
    jsonstr=$(add_json_string "WebFrameVer" "0" "$(get_sysinfo web.frame)" "${jsonstr}")
    jsonstr=$(add_json_string "WebRsrcVer" "0" "$(get_sysinfo web.rsync)" "${jsonstr}")
    jsonstr=$(add_json_string "CfgVer" "0" "$(get_sysinfo cfg.version)" "${jsonstr}")
    jsonstr=$(add_json_string "LastLoginTime" "0" "$(get_sysinfo login.time)" "${jsonstr}")
    jsonstr=$(add_json_string "LastLoginLat" "0" "$(get_sysinfo gps.Lat)" "${jsonstr}")
    jsonstr=$(add_json_string "LastLoginLng" "0" "$(get_sysinfo gps.Lng)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# CWanCount CWan0Model CWan0Meid CWan0FwVer CWan0Iccid CWan0Carrier CWan1Model CWan1Meid CWan1FwVer CWan1Iccid CWan1Carrier
get_json_md_waninfo() {
    local jsonstr=$@
    
    jsonstr=$(add_json_string "CWanCount" "0" "$(get_sysinfo cellular.count)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Model" "0" "$(get_sysinfo cellular1.model)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Meid" "0" "$(get_sysinfo cellular1.meid)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0FwVer" "0" "$(get_sysinfo cellular1.fw.version)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Iccid" "0" "$(get_sysinfo cellular1.iccid)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Carrier" "0" "$(get_sysinfo cellular1.carrier)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan1Model" "0" "$(get_sysinfo cellular2.model)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan1Meid" "0" "$(get_sysinfo cellular2.meid)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan1FwVer" "0" "$(get_sysinfo cellular2.fw.version)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan1Iccid" "0" "$(get_sysinfo cellular2.iccid)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan1Carrier" "0" "$(get_sysinfo cellular2.carrier)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# SdModel SdDisksize ExtWifiModel ExtWifiMAC ExtWifiSN
get_json_md_extinfo() {
    local jsonstr=$@

    jsonstr=$(add_json_string "SdModel" "0" "$(get_sysinfo sd.model)" "${jsonstr}")
    jsonstr=$(add_json_string "SdDisksize" "0" "$(get_sysinfo sd.size)" "${jsonstr}")
    jsonstr=$(add_json_string "ExtWifiModel" "0" "$(get_sysinfo extwifi.model)" "${jsonstr}")
    jsonstr=$(add_json_string "ExtWifiMAC" "0" "$(get_sysinfo extwifi.mac)" "${jsonstr}")
    jsonstr=$(add_json_string "ExtWifiSN" "0" "$(get_sysinfo extwifi.sn)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# MemorySize FlashSize FlashVendor FlashPsn HddVendor HddModel HddSN HddDisksize HddFwVer
get_json_md_boardinfo() {
    local jsonstr=$@

    jsonstr=$(add_json_string "MemorySize" "0" "$(get_sysinfo memory.size)" "${jsonstr}")
    jsonstr=$(add_json_string "FlashSize" "0" "$(get_sysinfo flash.size)" "${jsonstr}")
    jsonstr=$(add_json_string "FlashVendor" "0" "$(get_sysinfo flash.vendor)" "${jsonstr}")
    jsonstr=$(add_json_string "FlashPsn" "0" "$(get_sysinfo flash.psn)" "${jsonstr}")
    jsonstr=$(add_json_string "HddVendor" "0" "$(get_sysinfo hdd.vendor)" "${jsonstr}")
    jsonstr=$(add_json_string "HddModel" "0" "$(get_sysinfo hdd.model)" "${jsonstr}")
    jsonstr=$(add_json_string "HddSN" "0" "$(get_sysinfo hdd.sn)" "${jsonstr}")
    jsonstr=$(add_json_string "HddDisksize" "0" "$(get_sysinfo hdd.disksize)" "${jsonstr}")
    jsonstr=$(add_json_string "HddFwVer" "0" "$(get_sysinfo hdd.fw.version)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# ApVendor ApVer PcbaModel PcbaVersion HwMac HwPn HwVer
get_json_productinfo_b() {
    local jsonstr=$@

    jsonstr=$(add_json_string "ApVendor" "0" "$(get_sysinfo vendor)" "${jsonstr}")
    jsonstr=$(add_json_string "ApVer" "0" "$(get_sysinfo version)" "${jsonstr}")
    jsonstr=$(add_json_string "PcbaModel" "0" "$(get_sysinfo pcba.model)" "${jsonstr}")
    jsonstr=$(add_json_string "PcbaVersion" "0" "$(get_sysinfo pcba.version)" "${jsonstr}")
    jsonstr=$(add_json_string "HwMac" "0" "$(get_sysinfo hw.mac)" "${jsonstr}")
    jsonstr=$(add_json_string "HwPn" "0" "$(get_sysinfo hw.pn)" "${jsonstr}")
    jsonstr=$(add_json_string "HwVer" "0" "$(get_sysinfo hw.version)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# ApMac
get_json_mac() {
    local jsonstr=$@

    jsonstr=$(add_json_string "ApMac" "0" "$(get_sysinfo mac)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# ApSn ApModel
get_json_productinfo_a() {
    local jsonstr=$@

    jsonstr=$(add_json_string "ApSn" "0" "$(get_sysinfo sn)" "${jsonstr}")
    jsonstr=$(add_json_string "ApModel" "0" "$(get_sysinfo model)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

#
# {"ApMac":"00:1F:64:00:00:01","MemorySize":"2GB","HddVendor":"error","HddModel":"error",
# "HddSN":"error","CWanCount":"1","CWan0Model":"SIM6320C","CWan0Meid":"00A1000021ABE4EC",
# "CWan0Iccid":"89860314400200636599","CWan0Carrier":"CDMA2000","SwVer":"2.0.0.13","CfgVer":"invalid",
# "LastLoginLat":"40.0257331","LastLoginLng":"116.1752359"}
#
form_register_json() {
	local file=$(get_sysinfo_path file.register.v2)
	local jstring=""
	
	jstring=$(get_json_mac "${jstring}")
	jstring=$(get_json_productinfo_a "${jstring}")
	jstring=$(get_json_productinfo_b "${jstring}")
	jstring=$(get_json_md_boardinfo "${jstring}")
	jstring=$(get_json_md_extinfo "${jstring}")
	jstring=$(get_json_md_waninfo "${jstring}")
	jstring=$(get_json_md_funcinfo "${jstring}")

	echo ${jstring} > ${file}
}

#
# e.g. date -d '1970-01-01 08:00:14' -u '+%FT%TZ'
# e.g. awk -F '-' '{print $1"-"$2"-"$3" "$4":"$5":"$6}'
#
form_time_5min() {
	local time=$(date '+%FT%T')
	local time_date_hour=$(echo ${time}|awk -F ':' '{print $1}')
	local time_min=$(echo ${time}|awk -F ':' '{print $2}')

	time_min=$(echo ${time_min}|awk '{print $0/5}' | awk -F '.' '{print $1*5}')

	[[ ${time_min} -lt 10 ]] && time_min=0${time_min}
	time=${time_date_hour}:${time_min}:00Z
	echo ${time}
}

#
# json_time format is 0000-00-00T00:00:00Z
#
form_time_json() {
	local time_a=$1
	local time_b=$(echo ${time_a} | awk -F '-' '{print $1"-"$2"-"$3" "$4":"$5":"$6}')

	[[ -z "${time_a}" || -z "${time_b}" ]] && return

	local time=$(date --date="${time_b}" -u '+%FT%TZ')
	
	[[ "${time}" ]] && echo ${time}
}

# ApBillId BootTime LogTime
get_json_status_head() {
    local jsonstr=$@
    local boottime=$(form_time_json "$(cat /tmp/.startup)")
    local logtime=$(form_time_5min)

    jsonstr=$(add_json_string "ApBillId" "0" "$(get_sysinfo mac)+${boottime}" "${jsonstr}")
    jsonstr=$(add_json_string "BootTime" "0" "${boottime}" "${jsonstr}")
    jsonstr=$(add_json_string "LogTime" "0" "${logtime}" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# ApLat ApLng
get_json_md_gpsinfo() {
    local jsonstr=$@

    jsonstr=$(add_json_string "ApLat" "1" "$(get_sysinfo gps.Lat)" "${jsonstr}")
    jsonstr=$(add_json_string "ApLng" "1" "$(get_sysinfo gps.Lng)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# LoginStatus WifiSwitchStatus ApGroup ApIP 
get_json_status_a() {
    local jsonstr=$@

    jsonstr=$(add_json_string "LoginStatus" "0" "$(get_sysinfo login.status)" "${jsonstr}")
    jsonstr=$(add_json_string "WifiSwitchStatus" "0" "$(get_sysinfo wifi.status)" "${jsonstr}")
    jsonstr=$(add_json_string "ApGroup" "0" "$(get_sysinfo profile.ApGroup)" "${jsonstr}")
    jsonstr=$(add_json_string "ApIP" "0" "$(get_sysinfo cellular1.ip)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# CWan0OfflineCount CWan0OfflineSecs CWan0OnlineSecs CWan0OnlinePercent CWan0Csq CWan0Hdrcsq CWan0WorkMode
get_json_status_b() {
    local jsonstr=$@

    jsonstr=$(add_json_string "CWan0OfflineCount" "1" "$(get_sysinfo cellular1.offlinecount)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0OfflineSecs" "1" "$(get_sysinfo cellular1.offlinesecs)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0OnlineSecs" "1" "$(get_sysinfo cellular1.onlinesecs)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0OnlinePercent" "1" "$(get_sysinfo cellular1.onlinepercent)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Csq" "1" "$(get_sysinfo cellular1.csq)" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0Hdrcsq" "1" "$(get_sysinfo cellular1.strength | sed -n '$p')" "${jsonstr}")
    jsonstr=$(add_json_string "CWan0WorkMode" "0" "$(get_sysinfo cellular1.workmode)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# Wifi0AverageRssi Wifi1AverageRssi Wifi0AssociateUeCount Wifi1AssociateUeCount
get_json_status_c() {
    local jsonstr=$@
    
    jsonstr=$(add_json_string "Wifi0AverageRssi" "1" "$(get_sysinfo wifi0.rssi.avg)" "${jsonstr}")
    jsonstr=$(add_json_string "Wifi1AverageRssi" "1" "$(get_sysinfo wifi1.rssi.avg)" "${jsonstr}")
    jsonstr=$(add_json_string "Wifi0AssociateUeCount" "1" "$(get_sysinfo wifi0.uecount)" "${jsonstr}")
    jsonstr=$(add_json_string "Wifi1AssociateUeCount" "1" "$(get_sysinfo wifi1.uecount)" "${jsonstr}")

    [[ ${jsonstr} ]] && echo ${jsonstr}
}

# LoginUeCount 
# AllUserWanRxOcts AllUserWanTxOcts AllUserLanRxOcts AllUserLanTxOcts AllCWanRxOcts AllCWanTxOcts AllLanRxOcts AllLanTxOcts
get_json_status_d() {
	local jsonstr=$@

	jsonstr=$(add_json_string "LoginUeCount" "1" "$(get_sysinfo umc.auth.uecount)" "${jsonstr}")
	jsonstr=$(add_json_string "AllUserWanRxOcts" "1" "$(get_sysinfo umc.user.wan.rx)" "${jsonstr}")
    jsonstr=$(add_json_string "AllUserWanTxOcts" "1" "$(get_sysinfo umc.user.wan.tx)" "${jsonstr}")
    jsonstr=$(add_json_string "AllUserLanRxOcts" "1" "$(get_sysinfo umc.user.lan.rx)" "${jsonstr}")
    jsonstr=$(add_json_string "AllUserLanTxOcts" "1" "$(get_sysinfo umc.user.lan.tx)" "${jsonstr}")
    jsonstr=$(add_json_string "AllCWanRxOcts" "1" "$(get_sysinfo cellular1.down.flow)" "${jsonstr}")
    jsonstr=$(add_json_string "AllCWanTxOcts" "1" "$(get_sysinfo cellular1.up.flow)" "${jsonstr}")
    jsonstr=$(add_json_string "AllLanRxOcts" "1" "$(get_sysinfo lan.rx)" "${jsonstr}")
    jsonstr=$(add_json_string "AllLanTxOcts" "1" "$(get_sysinfo lan.tx)" "${jsonstr}")

	[[ ${jsonstr} ]] && echo ${jsonstr}
}

# BrdTemperature MemorySize MemoryFree MemoryUsedPercent CpuLoadaverage CpuUsedPercent 
# HddDisksize HddAvailable HddUsedPercent SdDisksize SdAvailable SdUsedPercent
# get number from string, e.g. sed -re 's/[^0-9]*([0-9]*).*$/\1/'
get_json_status_e() {
	local jsonstr=$@

    jsonstr=$(add_json_string "BrdTemperature" "1" "$(get_sysinfo temperature)" "${jsonstr}")
    jsonstr=$(add_json_string "MemorySize" "1" "$(get_sysinfo memory.size | sed -re 's/[^0-9]*([0-9]*).*$/\1000/')" "${jsonstr}")
    jsonstr=$(add_json_string "MemoryFree" "1" "$(get_sysinfo memory.free)" "${jsonstr}")
    jsonstr=$(add_json_string "MemoryUsedPercent" "1" "$(get_sysinfo memory.usedpct)" "${jsonstr}")
    jsonstr=$(add_json_string "CpuLoadaverage" "1" "$(get_sysinfo cpu.loadavg)" "${jsonstr}")
    jsonstr=$(add_json_string "CpuUsedPercent" "1" "$(get_sysinfo cpu.usedpct)" "${jsonstr}")
    jsonstr=$(add_json_string "HddDisksize" "1" "$(get_sysinfo hdd.disksize)" "${jsonstr}")
    jsonstr=$(add_json_string "HddAvailable" "1" "$(get_sysinfo hdd.available)" "${jsonstr}")
    jsonstr=$(add_json_string "HddUsedPercent" "1" "$(get_sysinfo hdd.usedpct)" "${jsonstr}")
    jsonstr=$(add_json_string "SdDisksize" "1" "$(get_sysinfo sd.size)" "${jsonstr}")
    jsonstr=$(add_json_string "SdAvailable" "1" "$(get_sysinfo sd.available)" "${jsonstr}")
    jsonstr=$(add_json_string "SdUsedPercent" "1" "$(get_sysinfo sd.usedpct)" "${jsonstr}")

	[[ ${jsonstr} ]] && echo ${jsonstr}
}

# WebFoldersToUpdate WebFoldersUpdated
get_json_status_webinfo() {
	local jsonstr=$@

    jsonstr=$(add_json_string "WebFoldersToUpdate" "0" "$(get_sysinfo web.floder.after)" "${jsonstr}")
    jsonstr=$(add_json_string "WebFoldersUpdated" "0" "$(get_sysinfo web.floder.now)" "${jsonstr}")

	[[ ${jsonstr} ]] && echo ${jsonstr}
}

# ApStatus LogoutTime LogoutCause
# $1: apstatus
# $2: logoutcause
get_json_status_tail() {
	local apstatus=$1
    local logoutcause=$2; shift 2
	local jsonstr=$@
    local logouttime=$(date '+%FT%TZ')

	if [[ ${apstatus} = "offline" ]]; then
		jsonstr=$(add_json_string "ApStatus" "0" "${apstatus}" "${jsonstr}")
	    jsonstr=$(add_json_string "LogoutTime" "0" "${logouttime}" "${jsonstr}")
	    jsonstr=$(add_json_string "LogoutCause" "0" "${logoutcause}" "${jsonstr}")
	elif [[ ${apstatus} = "online" ]]; then
		jsonstr=$(add_json_string "ApStatus" "0" "${apstatus}" "${jsonstr}")
	fi
	
	[[ ${jsonstr} ]] && echo ${jsonstr}
}

#
# $1: operation
# {"ApBillId":"00:1F:64:00:00:01+1970-01-01T08:00:13Z","BootTime":"1970-01-01T08:00:13Z","LogTime":"1970-01-01T14:25:00Z",
# "ApMac":"00:1F:64:00:00:01","ApLat":40.025788,"ApLng":116.1752443,"CWan0Hdrcsq":11,"MemorySize":2000,"ApStatus":"online"}
#
form_status_json() {
	local apstatus=$1
	local logoutcause=$2
	local file=$(get_sysinfo_path file.status.v2)
	local jstring=""
	
	jstring=$(get_json_status_head "${jstring}")
	jstring=$(get_json_productinfo_a "${jstring}")
	jstring=$(get_json_md_gpsinfo "${jstring}")
	jstring=$(get_json_status_a "${jstring}")
	jstring=$(get_json_status_b "${jstring}")
	jstring=$(get_json_status_c "${jstring}")
	jstring=$(get_json_status_d "${jstring}")
	jstring=$(get_json_status_e "${jstring}")
	jstring=$(get_json_status_webinfo "${jstring}")
	jstring=$(get_json_status_tail "${apstatus}" "${logoutcause}" "${jstring}")
	
	echo ${jstring} > ${file}
}

form_command_json() {
	local file=$(get_sysinfo_path file.command.v2)
	local jstring=""
	
	jstring=$(get_json_mac "${jstring}")

	echo ${jstring} > ${file}
}

#
# $1: operation
#
main () {
	local handle=$1
	local apstatus=$2
	local logoutcause=$3
	
	if [[ "${handle}" = "register" ]]; then
		form_register_json
	elif [[ "${handle}" = "command" ]]; then
		form_command_json
	elif [[ "${handle}" = "status" ]]; then
		if [[ ${apstatus} != "online" && ${apstatus} != "offline" ]]; then
			echo "Usage: get_sysinfo_json ${handle} [online|offline]"
			exit 1
		fi
		if [[ ${apstatus} = "offline" ]]; then
			case ${logoutcause} in
				poweroff|reboot|idleout)
					;;
				*)
					echo "Usage: get_sysinfo_json ${handle} ${apstatus} [poweroff|reboot|idleout]"
					exit 1				
					;;
			esac
		fi
		form_status_json "${apstatus}" "${logoutcause}"
		
	else
		echo "Usage: get_sysinfo_json [register|status|command]" && exit 1
	fi
}

main "$@"

