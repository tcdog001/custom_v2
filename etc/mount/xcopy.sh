#!/bin/bash

main() {
	local argc=$#
	local src="$1"
	local dst="$2"
	local err=0

	if ((2!=argc)); then
		return 1
	fi

	rsync -acq --delete --force --stats --partial "${src}" "${dst}"; err=$?
	if ((0!=err)); then
		rm -fr ${dst}/*
		cp -fpR ${src}/* ${dst}
	fi

       	sync	
}

main "$@"
