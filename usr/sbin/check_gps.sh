#!/bin/bash
. /usr/sbin/common_opera.in
. /etc/utils/utils.in

write_gps_log() {
        local gps_path=/tmp/.gps
        local recordtime=$1
        local resetcount=null
        local north_south=$(cat ${gps_path}/north_south 2>/dev/null)
        local lat=$(cat ${gps_path}/gps_Lat 2>/dev/null)
        local east_west=$(cat ${gps_path}/east_west 2>/dev/null)
        local lng=$(cat ${gps_path}/gps_Lng 2>/dev/null)
        local GPSdate=$(cat ${gps_path}/gps_time 2>/dev/null)
        local gps_logfile=${gps_path}/GPS.log

        printf '{"type":"GPS", "recordtime":"%s", "successtime":"%s", "resetcount":"%s", "latitude":"%s%s", "longitude":"%s%s", "GPSdate":"%s"}\n'   \
                "${recordtime}"     \
                "${GPSdate}"    \
                "${resetcount}"     \
                "${north_south}"    \
                "${lat}"            \
                "${east_west}"      \
                "${lng}"            \
                "${GPSdate}"        >> ${gps_logfile}
        fsync ${gps_logfile}
}
record_gps_log() {
        local gps_path=/tmp/.gps
        local state_file=${gps_path}/status
        local new_state=$1
        local old_state=$2
        local recordtime=$3

        if [[ (${new_state} -eq 1) && (${new_state} != ${old_state}) ]];then
                if [[ ${recordtime} ]];then
                        write_gps_log "${recordtime}"
                fi
        fi
}

main() {
        local interval=30
        local gps_path=/tmp/.gps
        local state_file=${gps_path}/status
        local log_file=/tmp/.gps.log
        local gps_state=""
        local gps_log=""
        local duration=""
        local time=""
        local recordtime="" 
        local old_state=0
        local i=0
        local j=0
	
	sleep 120
        while :
        do
                time=$(get_now_time)
                gps_state=$(cat ${state_file} 2>/dev/null)
                if [[ ${gps_state} -eq 1 ]];then
                        j=0
                else
                        ((j++))
                fi
                if [[ $j -ge 10 ]];then
                        duration=$((${j} * ${interval}))
                        jwaring_kvs GPS \
                                waring 'location_FAIL'   \
                                duration ${duration}  \
                                #end
                        ((i++))
                        if [[ $i -ge 6 ]];then
                                duration=$((${i} * ${j} * ${interval}))
                                jerror_kvs GPS \
                                        error 'location_FAIL'   \
                                        duration ${duration}  \
                                        #end
                                gps_log=$(cat ${log_file} 2>/dev/null)
                                if [[ -z ${gps_log} ]];then
                                        jnotice_kvs GPS \
                                                notice 'module_bad'        \
                                                #end
                                fi
                                i=0
                        fi
                        j=0
                fi

                if [[ (${gps_state} -eq 0) && (${old_state} -eq 1) ]];then 
                        recordtime=${time}                                      
                fi
                record_gps_log "${gps_state}" "${old_state}" "${recordtime}"
                old_state=$(cat ${state_file} 2>/dev/null)

                sleep ${interval}
        done
}

main "$@"
