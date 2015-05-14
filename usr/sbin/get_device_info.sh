#!/bin/bash

#common

. /etc/utils/utils.in
device_info_file="/data/device.info"

get_devinfo_cmd="/usr/sbin/get_sysinfo"
get_device_cpu_info() {
	local vendor=$(${get_devinfo_cmd} "cpu.vendor")
	local model=$(${get_devinfo_cmd} "cpu.model")
	local sn=$(${get_devinfo_cmd} "cpu.sn")
	local frequency=$(${get_devinfo_cmd} "cpu.clockspeed")
	
	echo "${vendor}-${model}-${sn}-${frequency}"

}

get_device_ram_info() {
	local vendor=$(${get_devinfo_cmd} "memory.vendor")
	local model=$(${get_devinfo_cmd} "memory.model")
	local sn=$(${get_devinfo_cmd} "memory.sn")
	local size=$(${get_devinfo_cmd} "memory.size")
	local frequency=$(${get_devinfo_cmd} "memory.clockspeed")
	
	echo "${vendor}-${model}-${sn}-${size}-${frequency}"
}

get_device_disk_info() {
	local vendor=$(${get_devinfo_cmd} "hdd.vendor")
	local model=$(${get_devinfo_cmd} "hdd.model")
	local sn=$(${get_devinfo_cmd} "hdd.sn")
	local size=$(${get_devinfo_cmd} "hdd.disksize")
	
	echo "${vendor}-${model}-${sn}-${size}"
}


get_device_wl24mac_info() {
	local vendor=$(${get_devinfo_cmd} "2gwifi.vendor")
	local model=$(${get_devinfo_cmd} "2gwifi.model")
	local sn=$(${get_devinfo_cmd} "2gwifi.sn")
	local mac=$(${get_devinfo_cmd} "2gwifi.mac")
	
	echo "${vendor}-${model}-${sn}-${mac}"
}

get_device_wl58mac_info() {
	local vendor=$(${get_devinfo_cmd} "5gwifi.vendor")
	local model=$(${get_devinfo_cmd} "5gwifi.model")
	local sn=$(${get_devinfo_cmd} "5gwifi.sn")
	local mac=$(${get_devinfo_cmd} "5gwifi.mac")
	
	echo "${vendor}-${model}-${sn}-${mac}"
}

get_device_gps_info() {
	local vendor=$(${get_devinfo_cmd} "gps.vendor")
	local model=$(${get_devinfo_cmd} "gps.model")
	local sn=$(${get_devinfo_cmd} "gps.sn")
	
	echo "${vendor}-${model}-${sn}"
}

get_device_3GModule_info() {
	local vendor=$(${get_devinfo_cmd} "cellular1.vendor")
	local model=$(${get_devinfo_cmd} "cellular1.model")
	local meid=$(${get_devinfo_cmd} "cellular1.meid")
	
	echo "${vendor}-${model}-${meid}"
}


get_gateway_version() {
	gateway_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"
	if [ -z "$gateway_version" ];then
		gateway_version=zj1.2
	fi
	echo "$gateway_version"
}

get_content_version() {
	content_version="`cat ${__CP_WEBSITE__}/ver.info 2>/dev/null`"
	if [ -z "$content_version" ];then
		content_version=zj1.2
	fi
	echo "$content_version"
}

get_device_info() {
	local recordtime=$(getnow)
	local code=$(${get_devinfo_cmd} "sn")
	local mac=$(${get_devinfo_cmd} "mac")
	local brand=$(${get_devinfo_cmd} "vendor")
	local model=$(${get_devinfo_cmd} "model")
	local factory=$(${get_devinfo_cmd} "company")
	local cpu=$(get_device_cpu_info)
	local ram=$(get_device_ram_info)
	local disk=$(get_device_disk_info)
	local ethmac=$(${get_devinfo_cmd} "lan.mac")
	local wl24mac=$(get_device_wl24mac_info)
	local wl58mac=$(get_device_wl58mac_info)
	local gps=$(get_device_gps_info)
	local Module_3G=$(get_device_3GModule_info)
	local sim_iccid=$(${get_devinfo_cmd} "cellular1.iccid")
	local date="none"
	local devver=$(${get_devinfo_cmd} "hw.version")
	local firmwarever=$(${get_devinfo_cmd} "sw.version")
	local portalver=$(${get_devinfo_cmd} "portal.version")
	local contentver=$(${get_devinfo_cmd} "content.version")
	
	printf '{"recordtime":"%s","code":"%s","mac":"%s","brand":"%s","model":"%s","factory":"%s","cpu":"%s","ram":"%s","disk":"%s","ethmac":"%s","wl24mac":"%s","wl58mac":"%s","gps":"%s","3GModule":"%s","sim-iccid":"%s","date":"%s","devver":"%s","firmwarever":"%s","portalver":"%s","contentver":"%s"}\n'  \
		"${recordtime}"	\
		"${code}"		\
		"${mac}"		\
		"${brand}"		\
		"${model}"	\
		"${factory}"		\
		"${cpu}"		\
		"${ram}"		\
		"${disk}"         \
		"${ethmac}"		\
		"${wl24mac}"		\
		"${wl58mac}"		\
		"${gps}"		\
		"${Module_3G}"		\
		"${sim_iccid}"		\
		"${date}"		\
		"${devver}"		\
		"${firmwarever}"		\
		"${portalver}"		\
		"${contentver}"

}

get_register_info() {
	local device_company=$(${get_devinfo_cmd} "vendor")
	local host_model=$(${get_devinfo_cmd} "model")
	local host_sn=$(${get_devinfo_cmd} "sn")
	local mac=$(${get_devinfo_cmd} "mac")
	local cpu_model=$(${get_devinfo_cmd} "cpu.model")
	local cpu_sn=$(${get_devinfo_cmd} "cpu.sn")
	local mem_model=$(${get_devinfo_cmd} "memory.model")
	local mem_sn=$(${get_devinfo_cmd} "memory.sn")
	local board_sn=$(${get_devinfo_cmd} "sn")
	local networkcard_mac=$(${get_devinfo_cmd} "lan.mac")
	local lowfre_model=$(${get_devinfo_cmd} "2gwifi.mac")
	local lowfre_sn=$(${get_devinfo_cmd} "2gwifi.sn")
	local hignfre_model=$(${get_devinfo_cmd} "5gwifi.mac")
	local hignfre_sn=$(${get_devinfo_cmd} "5gwifi.sn")
	local gps_model=$(${get_devinfo_cmd} "gps.model")
	local gps_sn=$(${get_devinfo_cmd} "gps.sn")
	local model_Of3g=$(${get_devinfo_cmd} "cellular1.model")
	local iccid=$(${get_devinfo_cmd} "cellular1.iccid")
	local hard_version=$(${get_devinfo_cmd} "hw.version")
	local firmware_version=$(${get_devinfo_cmd} "sw.version")
	local company_of3g=$(${get_devinfo_cmd} "cellular1.vendor")
	local meid_of3g=$(${get_devinfo_cmd} "cellular1.meid")	
	local sn_Of3g=$(${get_devinfo_cmd} "cellular1.sn")
	local Operators="CTCC"	
	local disk_model=$(${get_devinfo_cmd} "hdd.model")
	local disk_sn=$(${get_devinfo_cmd} "hdd.sn")
	local gateway_version=$(${get_devinfo_cmd} "portal.version")
	local content_version=$(${get_devinfo_cmd} "content.version")
	printf '{"hostCompany":"%s","hostModel":"%s","hostsn":"%s","mac":"%s","cpuModel":"%s","cpuSN":"%s","memoryModel":"%s","memorySN":"%s","boardSN":"%s","networkCardMac":"%s","lowFreModel":"%s","lowFreSN":"%s","hignFreModel":"%s","hignFreSN":"%s","gpsModel":"%s","gpsSN":"%s","MEID_3g":"%s","Company_3g":"%s","modelOf3g":"%s","snOf3g":"%s","iccid":"%s","Operators":"%s","hardVersion":"%s","firmwareVersion":"%s","diskModel":"%s","diskSN":"%s","gateWayVersion":"%s","contentVersion":"%s"\n}'   \
		"${device_company}" 	\
		"${host_model}" 	\
		"${host_sn}"    	\
		"${mac}"		\
		"${cpu_model}"  	\
		"${cpu_sn}"	     	\
		"${mem_model}"  	\
		"${mem_sn}"      	\
		"${board_sn}"   	\
		"${networkcard_mac}"	\
		"${lowfre_model}"	\
		"${lowfre_sn}"		\
		"${hignfre_model}"	\
		"${hignfre_sn}"		\
		"${gps_model}"		\
		"${gps_sn}"		\
		"${meid_of3g}"		\
		"${company_of3g}"	\
		"${model_Of3g}"		\
		"${sn_Of3g}"		\
		"${iccid}"		\
		"${Operators}"		\
		"${hard_version}" 	\
		"${firmware_version}" \
		"${disk_model}" \
		"${disk_sn}"	\
		"${gateway_version}"	\
		"${content_version}"
}

main() {
	#get_device_info > /tmp/device.info
	get_register_info > /data/.register.json
}

main "$@"

