#!/bin/bash

. /usr/sbin/get_3ginfo.in

main() {
        local imsi=""
        local company_3g=""
        local meid=""
        local iccid=""
        local net_3g=""
        local apn=""

        imsi=$(report_imsi_of3g)
        company_3g=$(report_company_of3g)
        iccid=$(report_sim_iccid)
        net_3g=$(report_net_3g)
        apn=$(get_apn)
	meid=$(report_meid_of3g)
}

main "$@"
