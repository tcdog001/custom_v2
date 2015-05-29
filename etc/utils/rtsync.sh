#!/bin/bash

. ${__ROOTFS__}/etc/utils/rtsync.in

main() {
	rtsync "$@"
}

main "$@"
