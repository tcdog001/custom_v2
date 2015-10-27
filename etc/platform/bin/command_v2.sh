#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL=$(get_sysinfo profile.MngServer)
	local URL_DEFAULT=https://lms1.autelan.com:8143/LMS/lte/

	command_operation_v2  "$URL" "$URL_DEFAULT"
}
main "$@"
