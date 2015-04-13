#!/bin/bash

main() {
	local dev="$1"
	local dir="$2"
	local err="$3"

	echo "mount ${dev} ${dir} error:${err}"
}

main "$@"
