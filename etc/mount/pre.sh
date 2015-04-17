#!/bin/bash

main() {
	local argc=$#
	local dev="$1"
	local dir="$2"
	local max

	if ((2!=argc)); then
		return 1
	fi

	max=$(tune2fs -l ${dev} | grep Maximum | awk -F ':' '{print $2}')

	if [[ "-1" != "${max}" ]]; then
		tune2fs -c 0 ${dev}
	fi
}

main "$@"
