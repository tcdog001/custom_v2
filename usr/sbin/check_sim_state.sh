#!/bin/bash

. /usr/sbin/get_3ginfo.in
. /usr/sbin/common_opera.in
. /etc/utils/utils.in
#
# check the SIM card, the interval is 300s
#
main() {
        sleep 10
        local interval=$(get_cycle_time "3g.conf.check_sim_state.interval" "300")
        local sim_state=""
        local i=1
        local j=1
        local sign=0

        while :
        do
                sim_state=$(get_sim_state)
                if [[ ${sim_state} != "READY" ]];then
                        if [[ ${sign} -eq 0 ]];then
                                jerror_kvs 3g_sim       \
                                        num ${i}      \
                                        sum ${j}      \
                                        #end
                                sign=1
                        fi
                        ((i++))
                        ((j++))
                else
                        sign=0
                        i=1
                fi
                sleep ${interval}
        done
}

main "$@"
