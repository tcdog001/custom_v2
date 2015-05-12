#!/bin/sh

. /etc/platform/bin/platform.in

CERTIFICATE=/etc/platform/conf/server.cer
USER_PASSWD=autelanauteviewlms:autelanauteviewlms20140925
URL_PATH=/etc/platform/conf/platform.json
URL_DEFAULT=https://atbus.9797168.com:8443/LMS/lte/
COOKIE_FILE=/tmp/registerCookie.txt
PAGE=lteRegister.do
RESULT_FILE=/tmp/registerResult.txt
CURLE_OK=0
CURLE_COULDNT_CONNECT=7
CURLE_COULDNT_RESOLVE_HOST=6
RECONNECTION_INTERVAL=5

get_cancellation_log() {
	local mac=$(/usr/sbin/get_sysinfo "mac")
	printf '{"mac":"%s"}\n' \
	"${mac}" > $FILE_CANCELLATION
}


if [ -f $RESULT_FILE ];then
	rm $RESULT_FILE
fi

while [ ! -f $FILE_CANCELLATION ]; do
	sleep 5
done

if [ -f $FILE_CANCELLATION ];then
	if [ -s $URL_PATH ];then
		url_path=`cat $URL_PATH |jq -j '.url'`
		url=${url_path}${PAGE}
	else
		url=${URL_DEFAULT}${PAGE}
	fi
	echo url=$url
	
	while true
	do
		curl  -k  -cert $CERTIFICATE  -u $USER_PASSWD  -H "Content-type: application/json"  -X POST  -d @$FILE_CANCELLATION -s  -c $COOKIE_FILE  $url > $RESULT_FILE
		response=$?
		echo response=$response
#		if [ $response -eq $CURLE_COULDNT_CONNECT ] || [ $response -eq $CURLE_COULDNT_RESOLVE_HOST ];then
		if [ $response != $CURLE_OK ]; then
			sleep $RECONNECTION_INTERVAL
		else
			break
		fi
	done

	out=`cat $RESULT_FILE |jq '.code'`
	echo out=$out
	case $out in
		0) 
			echo "register success!"
			;;
		-1)	
			echo "user/password error!"
			;;
		*) 
			echo "register fail!"
			;;
	esac
#	if [ -f $RESULT_FILE ];then
#		rm $RESULT_FILE
#	fi
else
	echo $FILE_CANCELLATION" is not exist!"
fi


