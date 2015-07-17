#!/bin/bash

main() {

	local interval=$1

	acc_exit
	sleep 1
	set_confinfo acc.conf.acc_monitor.timeout "${interval}"
	sleep 1
	acc_init
}
main "$@"
