#!/bin/bash

. /usr/sbin/3g/common_opera.in
#. /tmp/common_opera.in
path_3g=/tmp/3g

#
# According to the apn and tel, start the 3g_sample
#
start_3g() {
        local telephone=$(cat ${path_3g}/tel 2>/dev/null)
        local apn=$(cat ${path_3g}/apn 2>/dev/null)
        local start_file=${path_3g}/start_3g


        if [[ "${telephone}" && "${apn}" ]];then
                3g_sample ${telephone} "card" "card" ${apn} &
        else
                logger -t $0 "telephone=${telephone},apn=${apn}"
                3g_sample "#777" "card" "card"  "ctnet" &
        fi
}
#
# Remove excess the 3g_sample and start 3g_sample
#
start_ppp() {
        kill_process 3g_sample
        start_3g
        sleep 40
	syn_net_time
        local endtime=$(get_now_time)
        echo ${endtime} > ${path_3g}/end_dial_time
}

main() {
        local start_dial_time_file=${path_3g}/start_dial_time
        local start_dial_time=$(cat ${start_dial_time_file} 2>/dev/null)
        if [[ -z ${start_dial_time} ]];then
                start_dial_time=$(get_now_time)
                echo ${start_dial_time} >${path_3g}/start_dial_time
        fi
        while :
        do
                local state_file=${path_3g}/3g_state.log
                local state_3g=$(cat ${state_file} 2>/dev/null)

                if [[ -z ${state_3g} || ${state_3g} != 0 ]];then
                        local num=$(cat ${path_3g}/dialcount 2>/dev/null)
                        num=$(($num+1))
                        echo ${num} >${path_3g}/dialcount
                        start_ppp
                fi
                sleep 10
        done
}

main "$@"
