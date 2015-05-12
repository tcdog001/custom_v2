#!/bin/bash

. /usr/sbin/common_opera.in

path_3g=/tmp/.3g
path_data_3g=/data/3g
#
# set the end time of dial
#
report_enddial_time() {
        local end_dialtime=$(get_now_time)
        echo ${end_dialtime} > ${path_3g}/end_dial_time; fsync ${path_3g}/end_dial_time
}
#
# record the first dial time to ${path_3g}/start_dial_time
#
record_first_dialtime() {
        local start_dial_time_file=${path_3g}/start_dial_time
        local start_dial_time=$(cat ${start_dial_time_file} 2>/dev/null)
        if [[ -z ${start_dial_time} ]];then
                start_dial_time=$(get_now_time)
                echo ${start_dial_time} > ${path_3g}/start_dial_time; fsync ${path_3g}/start_dial_time
        fi
}
#
#repord the dial count
#
record_dialcount() {
        local num=$(cat ${path_3g}/dialcount 2>/dev/null)
        num=$(($num+1))
        echo ${num} >${path_3g}/dialcount; fsync ${path_3g}/dialcount
}
#
# According to the apn and tel, start the 3g dial
#
start_3g() {
        local tel=$(cat ${path_3g}/tel 2>/dev/null)
        local apn=$(cat ${path_3g}/apn 2>/dev/null)
        local data_tel=$(cat ${path_data_3g}/tel 2>/dev/null)
        local data_apn=$(cat ${path_data_3g}/apn 2>/dev/null)

        if [[ "${tel}" && "${apn}" ]];then
                ppp_dial ${tel} "card" "card" ${apn} &
        else
                if [[ "${data_tel}" && "${data_apn}" ]];then
                        logger -t $0 "NOT find tel and apn !"
                        ppp_dial ${data_tel} "card" "card" ${data_apn} &
                else
                        logger -t $0 "NOT find tel, apn, data_tel and data_apn !"
                        ppp_dial "#777" "card" "card"  "ctnet" &
                fi
        fi
}
#
# Remove excess the ppp_dial and start ppp_dial
#
start_ppp() {
        start_3g
	syn_net_time
}
main() {
        local interval=$(cat /tmp/config/interval_3g.in | awk '/3g_connect/{print $2}' 2>/dev/null)
        if [[ -z ${interval} ]];then
                interval=10
        fi
        record_first_dialtime
        while :
        do
                local state_file=${path_3g}/3g_state.log
                local state_3g=$(cat ${state_file} 2>/dev/null)

                if [[ -z ${state_3g} || ${state_3g} != 0 ]];then
                        local ps_line=$(ps |grep ppp_dial |wc -l 2>/dev/null)
                        case ${ps_line} in
                                "1")
                                        report_enddial_time
                                        record_dialcount
                                        start_ppp
                                        ;;
                                "2")
                                        ;;
                                *)
                                        killall -9 ppp_dial 2>/dev/null
                                        report_enddial_time
                                        record_dialcount
                                        start_ppp
                                        ;;
                        esac
                fi
                sleep ${interval}
        done
}

main "$@"
