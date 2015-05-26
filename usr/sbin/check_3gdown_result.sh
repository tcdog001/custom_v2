#!/bin/bash

. /usr/sbin/get_3ginfo.in
. /usr/sbin/common_opera.in
. /etc/utils/utils.in

path_3g=/tmp/.3g
#
# restart the lte modules
#
restart_lte_modules() {
        local resetcount=$(cat ${path_3g}/resetcount 2>/dev/null)
        if [[ -z ${resetcount} ]];then
                resetcount=0
        else
                resetcount=$((${resetcount}+1))
        fi
        echo ${resetcount} >${path_3g}/resetcount; fsync ${path_3g}/resetcount
        jnotice_kvs 3g \
                notice 'retstart_module'        \
                #end
        /usr/sbin/cdma_off 2>/dev/null
        sleep 1
        /usr/sbin/cdma_on 2>/dev/null
}
#
# check the number of /dev/ttyUSB*
# MC271X : 4
# SIM6320C : 5
# DM111 : 2
# if the number of /dev/ttyUSB* is error, restart the 3g module
#
check_lte_modules() {
        local model=$(cat ${path_3g}/3g_model 2>/dev/null)
        local ttyUSB_sum=$(ls /dev/ttyUSB* |wc -w)

        case ${model} in
                "MC271X")
                        if [[ ${ttyUSB_sum} -ne 4 ]];then
                                restart_lte_modules
                        fi
                        ;;
                "SIM6320C")
                        if [[ ${ttyUSB_sum} -ne 5 ]];then
                                restart_lte_modules
                        fi
                        ;;
                "DM111")
                        if [[ ${ttyUSB_sum} -ne 2 ]];then
                                restart_lte_modules
                        fi
                        ;;
                *)
                        ;;
        esac
}
#
#check the SIM card
#
check_sim() {
        local sim_state=$(cat ${path_3g}/sim_state 2>/dev/null)
        if [[ ${sim_state}  != "READY" || -z ${sim_state} ]];then
                jerror_kvs 3g  \
                        error 'no_sim_card'       \
                        #end
                return 1
        fi
}
#
# check the signal strength
#
check_hdrcsq() {
        local model=$(cat ${path_3g}/3g_model 2>/dev/null)
        local hdrcsq_file=${path_3g}/hdrcsq
        local signal1=$(cat ${hdrcsq_file} |tail -n 1 2>/dev/null)
        local signal2=$(cat ${hdrcsq_file} |tail -n 2 |sed -n '1p' 2>/dev/null)

       case ${model} in
               "MC271X")
                       if [[ ${signal1} < 20 && ${signal2} < 20 ]];then
                                jnotice_kvs 3g  \
                                        signal1 ${signal1}    \
                                        signal2 ${signal2}    \
                                        notice 'signal_weak'    \
                                        #end
                                return 1
                       fi
                       ;;
               "C5300V")
                       if [[ ${signal1} < 20 && ${signal2} < 20 ]];then
                                jnotice_kvs 3g  \
                                        signal1 ${signal1}    \
                                        signal2 ${signal2}    \
                                        notice 'signal_weak'    \
                                        #end
                                return 1
                       fi
                       ;;
               "SIM6320C")
                       if [[ ${signal1} < 10 || ${signal1} == 99 ]];then
                                if [[ ${signal2} == 99 || ${signal2} < 10 ]];then
                                jnotice_kvs 3g  \
                                        signal1 ${signal1}    \
                                        signal2 ${signal2}    \
                                        notice 'signal_weak'    \
                                        #end
                                        return 1
                                fi
                       fi
                       ;;
               "DM111")
                       if [[ ${signal1} < 10 || ${signal1} == 99 ]];then
                                if [[ ${signal2} == 99 || ${signal2} < 10 ]];then
                                jnotice_kvs 3g  \
                                        signal1 ${signal1}    \
                                        signal2 ${signal2}    \
                                        notice 'signal_weak'    \
                                        #end
                                        return 1
                                fi
                       fi
                       ;;
               *)
                        return 1
                        ;;
       esac
}
#
# the beginning of the program
#
start_check() {
        check_lte_modules
        check_sim
        check_hdrcsq
        killall -9 3g_connect.sh 2>/dev/null
	killall -9 ppp_dial 2>/dev/null
	killall -9 pppd 2>/dev/null
}
