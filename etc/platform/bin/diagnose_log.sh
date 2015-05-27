#!/bin/bash

. /etc/platform/bin/platform.in
. /etc/utils/dir.in 


main() {

	local output=/tmp/aute_syslog.out
	host=oss-cn-hangzhou.aliyuncs.com
	bucket="lms9-autelan-com"
	Id=WRIBSFML486WciQr
	Key=HY5YRv4cfqmbaOmf8JwIjFxPmtootb
	contentType="application/x-compressed-tar"
	local status
	
	for file in $(ls ${dir_tmp_log_aute}/aute_jlog-* | sort -r); do
		
	        filename=${file##*/}.tar.gz	
		cd ${dir_tmp_log_aute}
		tar -cvf ${filename} ${file}
		
		resource="/${bucket}/${filename}"
		dateValue="`TZ=GMT date +'%a, %d %b %Y %H:%M:%S GMT'`"
		#dateValue=`date -R`
		stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
		
		signature=`echo -en ${stringToSign} | OPENSSL_CONF=/usr/local/ssl/openssl.cnf /usr/local/bin/openssl sha1 -hmac ${Key} -binary | base64`
		
		status=$(curl -i -q -X PUT -T "${file}" \
		 -H "Host: ${host}" \
		  -H "Date: ${dateValue}" \
		  -H "Content-Type: ${contentType}" \
		   -H "Authorization: OSS ${Id}:${signature}" \
		   http://${host}/${bucket}/${filename})
        if [ "$status" -eq "200" ];then
			rm -f ${file} > /dev/null 2>&1
		else
			echo "$(getnow) upload ${file} status=${status}" >> ${output}
		fi
		rm -rf ${dir_tmp_log_aute}/${filename}
		sleep 1
		
	done
}

main "$@"

