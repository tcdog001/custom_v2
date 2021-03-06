#!/bin/bash

. ${__ROOTFS__}/etc/upgrade/upgrade_ap.in

#
#$1:prefix
#
main() {
	local prefix=$1

	jsock_md_send_check || {
		return ${e_bad_board}
	}

	upgrade_ap_with_flock ${prefix} || return $?
}

main "$@"
