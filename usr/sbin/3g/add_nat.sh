#!/bin/bash

. /usr/sbin/3g/common_opera.in
#. /tmp/common_opera.in

main() {
        sleep 10
        add_nat
}
main "$@"
