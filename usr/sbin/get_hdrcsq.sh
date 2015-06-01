#!/bin/bash

. /usr/sbin/get_3ginfo.in
. /usr/sbin/common_opera.in
. /etc/utils/utils.in

path_3g=/tmp/.3g

check_signal() {
        local model=$(cat ${path_3g}/3g_model 2>/dev/null)
        local hdrcsq_file=${path_3g}/hdrcsq
        local signal1=$(cat ${hdrcsq_file} |tail -n 1 2>/dev/null)
        local signal2=$(cat ${hdrcsq_file} |tail -n 2 |sed -n '1p' 2>/dev/null)

        case ${model} in
               "MC271X")
                       check_hdrcsq ${signal1} ${signal2}
                       ;;
               "C5300V")
                       check_hdrcsq ${signal1} ${signal2}
                       ;;
               "SIM6320C")
                       check_csq ${signal1} ${signal2}
                       ;;
               "DM111")
                        check_csq ${signal1} ${signal2}
                        ;;
               *)
                        ;;
       esac
}

#
# get the 3g signal stringth , the interval is 30s
# delete the old data in the file of 3g signal strength
#
main() {
        local interval=$(get_confinfo "3g.conf.get_hdrcsq.interval" 2>/dev/null)

        while :
        do
                sleep 7
                local hdrcsq=$(report_hdrcsq)
                local hdrcsq_file=${path_3g}/hdrcsq
                echo ${hdrcsq} >> ${hdrcsq_file}; fsync ${hdrcsq_file}
                check_signal

                local line=$(cat ${hdrcsq_file} |wc -l 2>/dev/null)             
                local del_line=$(awk 'BEGIN{printf("%d",'${line}'-'5')}')
                if [[ ${line} -gt 5 ]];then
                        sed -e "1,${del_line}"d ${hdrcsq_file} -i 2>/dev/null
                fi
                sleep ${interval}
        done
}

main "$@"
