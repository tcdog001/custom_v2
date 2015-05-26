#!/bin/bash

add_nat() {
	iptable -t nat --list |grep MASQUERADE >/dev/null 2>&1; local ret_nat=$?
	if [[ ${ret_nat} -ne 0 ]];then
		iptables -t nat  -A POSTROUTING -o ppp0  -j  MASQUERADE
	fi
}
main() {
        sleep 10 
        add_nat
        while :
        do
                route |grep default |grep ppp0 >/dev/null 2>&1; local ret_route=
                if [[ ${ret_route} -ne 0 ]];then
                        route add default ppp0 2>/dev/null
                else
                        break
                fi
                sleep 10
	done
}

main "$@"

