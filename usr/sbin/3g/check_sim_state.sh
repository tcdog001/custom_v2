#!/bin/bash

. /usr/sbin/3g/get_3ginfo.in
#. /tmp/get_3ginfo.in
#
# check the SIM card, the interval is 30s
#
main() {
        local sim_state=""
        while :
        do
                sim_state=$(get_sim_state)
                sleep 30
        done
}

main "$@"
