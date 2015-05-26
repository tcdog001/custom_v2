#!/bin/bash

. ${__ROOTFS__}/etc/utils/dir.in

#
#$1:remote
#$2:dir
#

sysconfig_config_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2
	local server=$3
	local port="873"
	#local server="lms1.autelan.com"
	
	local user="autelan"
	#local user="root"
	#local pass="ltefi@Autelan1"
	local timeout="300"

	local sshparam="sshpass -p ${pass} ssh -l ${user} -o StrictHostKeyChecking=no"
	local rsync_dynamic=" --timeout=${timeout}"
	local rsync_static="-acz --delete --force --stats --partial"
	local pass="--password-file=/etc/rsyncd.pass"
	local action="rsync ${rsync_dynamic} ${rsync_static} ${user}@${server}::systemconfig/${remote} ${dir} ${pass}"

	local err=0
	eval "${action}"; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

sysconfig_rsync() {
	local remote=$1; remote=${remote%/}/
	local dir=$2
	local server=$3
	
	local port="873"
	#local server="zjweb.autelan.com"
	local user="autelan"
	#local user="root"
	#local pass="ltefi@Autelan1"
	local timeout="300"

	local sshparam="sshpass -p ${pass} ssh -l ${user} -o StrictHostKeyChecking=no"
	local rsync_dynamic=" --timeout=${timeout}"
	local rsync_static="-acz --delete --force --stats --partial"
	local pass="--password-file=/etc/rsyncd.pass"
	local action="rsync ${rsync_dynamic} ${rsync_static} ${user}@${server}::systemconfig/${remote} ${dir} ${pass}"

	local err=0
	eval "${action}"; err=$?
	echo_logger "website" "$(get_error_tag ${err}): rsync ${remote}"
	if ((0!=err)); then
		return ${err}
	fi
}

sysconfig_local_version() {
	local file=${dir_sysconfig_config}/ver.info

	if [[ -f ${file} ]]; then
		cat ${file}
	else
		logger "lose ver.info"
	fi
}

sysconfig_version() {
	local version=$(sysconfig_local_version)
	local target=$(awk -v version=${version} '{if ($1==version) print $2}' ${file_sysconfig_config})
	case $(echo ${target} | wc -l) in
	0)
		logger "sysconfig" "no found version, needn't upgrade"
		;;
	1)
		logger "sysconfig" "need upgrade: ${version}==>${target}"

		echo "${target}"
		;;
	*)
		logger "sysconfig" "too more version, don't upgrade"
		;;
	esac
}

sysconfig_upgrade() {
	local config_url="$1"
	local ver_url="$2"
	local version="$3"

	if [[ -z "${version}" ]]; then
		#
		# get config
		#
		#website_rsync /opt/version/lte-fi/website/website_config ${dir_website_config} || return $?
		sysconfig_config_rsync download_config ${dir_sysconfig_config} "${config_url}" || return $?
		if [[ ! -f "${file_sysconfig_config}" ]]; then
			logger "sysconfig" "no found ${file_sysconfig_config}"
	
			return
		fi
	
		#
		# read config
		#
		version=$(sysconfig_version) || return $?
		if [[ -z "${version}" ]]; then
			return
		fi
	fi

	#
	# do upgrade
	#
	#website_rsync /opt/version/lte-fi/website/${version} ${dir_website_upgrade} || return $?
	local sysconfig_upgrade_dir=${dir_sysconfig_upgrade}/${version}
	sysconfig_rsync ${version} "${sysconfig_upgrade_dir}" "${ver_url}"|| return $?
#	mv ${sysconfig_upgrade_dir}/ver.info ${dir_sysconfig_config}/ver.info.bak; sync
#	cp -fpR ${sysconfig_upgrade_dir}/* ${dir_sysconfig_config}; sync
#	mv ${dir_sysconfig_config}/ver.info.bak ${dir_sysconfig_config}/ver.info; sync
}

main() {
	local config_url="$1"
	local ver_url="$2"
	local version="$3"
	
	local err=0

	sleep 60

	for ((;;)); do
		sysconfig_upgrade "${config_url}" "${ver_url}" "${version}" && return

		sleep 300
	done
}

main "$@"

