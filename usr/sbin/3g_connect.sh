#!/bin/bash

. /usr/sbin/common_opera.in
. /etc/utils/utils.in

path_3g=/tmp/.3g
path_data_3g=/data/3g

#
# According to the apn and tel, start the 3g dial
#
start_ppp() {
        local tel=$(cat ${path_3g}/tel 2>/dev/null)
        local apn=$(cat ${path_3g}/apn 2>/dev/null)
        local data_tel=$(cat ${path_data_3g}/tel 2>/dev/null)
        local data_apn=$(cat ${path_data_3g}/apn 2>/dev/null)

        if [[ "${tel}" && "${apn}" ]];then
                ppp_dial ${tel} "card" "card" ${apn} 1>/dev/null &
        else
                if [[ "${data_tel}" && "${data_apn}" ]];then
                        jdebug_event "3g_info" "no_dialinfo"
                        ppp_dial ${data_tel} "card" "card" ${data_apn} 1>/dev/null &
                else
                        jinfo_kvs "3g_info"  \
                                info 'no_data_dialinfo'	\
				                #end
                        ppp_dial "#777" "card" "card"  "ctnet" 1>/dev/null &
                fi
        fi
}

main() {
        local interval=$(get_cycle_time "3g.conf.3g_connect.interval" "10")

	    sleep ${interval}
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
