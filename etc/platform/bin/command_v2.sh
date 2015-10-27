#!/bin/sh

. /etc/platform/bin/platform.in

main() {
	local URL_PATH=$(get_sysinfo_path profile.MngServer)
	local URL_DEFAULT=https://lms1.autelan.com:8143/LMS/lte/

	command_operation_v2  "$URL_PATH" "$URL_DEFAULT"
}
main "$@"
