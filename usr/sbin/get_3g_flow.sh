#!/bin/bash
. /usr/sbin/common_opera.in

main() {
        local interval=$(get_confinfo "3g.conf.get_3g_flow.interval" 2>/dev/null)
        if [[ -z ${interval} ]];then
                interval=300
        fi
        while :
        do
                sleep ${interval}
                get_3g_flow
        done
}
main "$@"
