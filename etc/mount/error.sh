#!/bin/bash

main() {
	local argc=$#
	local dev="$1"
	local dir="$2"
	local err="$3"

	if ((3!=argc)); then
		return 1
	fi

	echo "mount ${dev} ${dir} error:${err}"
}

main "$@"
