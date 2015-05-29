#!/bin/bash

main() {
	local dir event file

	inotifywait -mr -e modify,moved_to,create,delete /mnt/flash/data \
		| while read dir event file; do
			
		done
}

main "$@"
