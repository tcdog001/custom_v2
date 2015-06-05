#!/bin/bash

. ${__ROOTFS__}/etc/utils/dir.in

main() {
	setup_dir_default
}

main "$@"
