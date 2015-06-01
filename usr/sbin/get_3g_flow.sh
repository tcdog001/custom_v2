#!/bin/bash
. /usr/sbin/common_opera.in

main() {
        local interval=$(get_cycle_time "3g.conf.get_3g_flow.interval" "300")

        while :
        do
                sleep ${interval}
                get_3g_flow
        done
}
main "$@"
