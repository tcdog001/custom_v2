#!/bin/bash
. /usr/sbin/common_opera.in
#. /tmp/common_opera.in
main() {
        local interval=$(cat "/usr/sbin/interval.in" | awk '/get_3g_flow/{print $2}' 2>/dev/null)
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
