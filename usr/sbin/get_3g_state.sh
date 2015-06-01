#!/bin/bash

. /usr/sbin/check_3gnet.in
. /usr/sbin/check_3gdown_result.in
. /usr/sbin/common_opera.in

main () {
        local interval=$(get_cycle_time "3g.conf.get_3g_state.interval" "10")
        local num=0
        while :
        do
                sleep ${interval}
		check_ppp0

                local state=$(cat ${state_file} 2>/dev/null)
                if [[ ${state} -eq 0 ]];then
                        set_3g_led "on"
                        num=0
			record_first_time
                else
                        set_3g_led "off"
                        num=$(($num+1))
                        local num2=$((${num} % 9))
                        if [[ ${num} -gt 180 ]];then
                                local duration=$((${num} * 30))
                                drop_3g_log_30min "${duration}"
                                start_check
                                num=0
                        else
                                if [[ ${num2} -eq 0 ]];then
                                        drop_3g_log
                                        start_check
                                fi
                        fi
                fi
        done
}

main "$@"
