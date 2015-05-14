#!/bin/bash

. /usr/sbin/get_3ginfo.in
. /usr/sbin/common_opera.in
. /etc/utils/utils.in

path_3g=/tmp/.3g

check_hdrcsq() {
        local model=$(cat ${path_3g}/3g_model 2>/dev/null)
        local hdrcsq_file=${path_3g}/hdrcsq
        local signal1=$(cat ${hdrcsq_file} |tail -n 1 2>/dev/null)
        local signal2=$(cat ${hdrcsq_file} |tail -n 2 |sed -n '1p' 2>/dev/null)

       case ${model} in
               "MC271X")
                       if [[ ${signal1} -le 20 && ${signal2} -le 20 ]];then
                                record_log ${signal1} ${signal2}
                                return 1
                       fi
                       ;;
               "C5300V")
                       if [[ ${signal1} -le 20 && ${signal2} -le 20 ]];then
                                record_log ${signal1} ${signal2}
                                return 1
                       fi
                       ;;
               "SIM6320C")
                       if [[ ${signal1} -le 10 || ${signal1} -eq 99 ]];then
                                if [[ ${signal2} -eq 99 || ${signal2} -le 10 ]];then
                                        record_log ${signal1} ${signal2}
                                        return 1
                                fi
                       fi
                       ;;
               "DM111")
                       if [[ ${signal1} -le 10 || ${signal1} -eq 99 ]];then
                                if [[ ${signal2} -eq 99 || ${signal2} -le 10 ]];then
                                        record_log ${signal1} ${signal2}
                                        return 1
                                fi
                       fi
                       ;;
               *)
                        return 1
                        ;;
       esac
}
record_log() {
        local time=$(get_now_time)
        local signal_1=$1
        local signal_2=$2
        local gps_state=$(cat /tmp/.gps/status 2>/dev/null)
        local east_west=""
        local gps_Lng=""
        local north_south=""
        local gps_Lat=""
        local gps_location=""
        if [[ (-z ${gps_state}) || (${gps_state} -eq 1) ]];then
                gps_location="null"
        else
                east_west=$(cat /tmp/.gps/east_west 2>/dev/null)
                gps_Lng=$(cat /tmp/.gps/gps_Lng 2>/dev/null)
                north_south=$(cat /tmp/.gps/north_south 2>/dev/null)
                gps_Lat=$(cat /tmp/.gps/gps_Lat 2>/dev/null)
                gps_location=${east_west}${gps_Lng}${north_south}${gps_Lat}
        fi
        jnotice_kvs '3g'  \
                notice 'hdrcsq_weak'    \
                signal1 '${signal1}'    \
                signal2 '${signal2}'    \
                #end
}
#
# get the 3g signal stringth , the interval is 30s
# delete the old data in the file of 3g signal strength
#
main() {
        local interval=$(cat "/tmp/config/interval_3g.in" | awk '/get_hdrcsq/{print $2}' 2>/dev/null)

        if [[ -z ${interval} ]];then
                interval=30
        fi
        while :
        do
                sleep 7
                local hdrcsq=$(report_hdrcsq)
                local hdrcsq_file=${path_3g}/hdrcsq
                echo ${hdrcsq} >> ${hdrcsq_file}; fsync ${hdrcsq_file}
                check_hdrcsq

                local line=$(cat ${hdrcsq_file} |wc -l 2>/dev/null)             
                local del_line=$(awk 'BEGIN{printf("%d",'${line}'-'5')}')
                if [[ ${line} -gt 5 ]];then
                        sed -e "1,${del_line}"d ${hdrcsq_file} -i 2>/dev/null
                fi
                sleep ${interval}
        done
}

main "$@"
