#!/bin/bash
. /usr/sbin/3g/common_opera.in
#. /tmp/common_opera.in
main() {
        while :
        do
                sleep 300
                get_3g_flow
        done
}
main "$@"
