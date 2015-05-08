#!/bin/bash

. /usr/sbin/get_3ginfo.in
. /usr/sbin/common_opera.in
#
# check the SIM card, the interval is 300s
#
main() {
        sleep 10
        local sim_state=""
        local i=1
        local j=1
        local sim_log=${path_3g}/sim.log
        local time=$(get_now_time)
        local interval=$(cat "/usr/sbin/interval.in" | awk '/check_sim_state/{print $2}' 2>/dev/null)
        if [[ -z ${interval} ]];then
                interval=300
        fi
        while :
        do
                sim_state=$(get_sim_state)
                if [[ ${sim_state} != "READY" ]];then
                        printf '{"time":"%s", "num":"%d", "sum":"%d"}\n'   \
                                "${time}"       \
                                "$i"            \
                                "$j"      >> ${sim_log}
                        ((i++))
                        ((j++))
                else
                        i=1
                fi
                sleep ${interval}
        done
}

main "$@"
