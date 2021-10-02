#!/bin/bash
BASEDIR=$1
OCPTOKEN=$2
OCPSERVER=$3
OCPINGRESS=$4

# Do not change


function _formatArrayElem() {
	FILENAME=$1
	FIRST=true
	while read -r LINE; do 
		NOCH=`echo ${LINE} | sed "s/\"/\'/g"`
		if [[ .${FIRST}. == .true. ]]; then
			FIRST=false
		else
			if [[ .${NOCH}. != .. ]]; then printf ', '; fi
		fi
		if [[ .${NOCH}. != .. ]]; then printf '"%s"' "${NOCH}"; fi
	done < ${FILENAME}
}

function prepareActions() {
	# login to openshift cluster
	oc login --token="${OCPTOKEN}" --server="${OCPSERVER}" > /dev/null 2>&1
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 1, "desc" : "Cannot login to openshift cluster.", "data" : []'
		exit 1
	fi
}

prepareActions

printf '{ "status" : 0, "desc" : "Success", "data" : ['
FIRST=true
for P in `oc get projects | grep Active | awk '{ if ($1 == "*") { print $2 } else { print $1} }' | grep "^instance-" | sed 's/^instance-//g'`; do
	K=`find ${BASEDIR} -name tenant.${P}.log | head -1 | sed "s#${BASEDIR}##" | sed 's#/# #g' | xargs`
    if [[ .${FIRST}. == .true. ]]; then
        if [[ .${K}. != .. ]]; then
            FIRST=false
        fi
    else
        if [[ .${K}. != .. ]]; then
            printf ', '
        fi
    fi
	if [[ .${K}. != .. ]]; then
		PAPPNAME=`echo $K | awk '{print $1}'`
		APPVER=`echo $K | awk '{print $2}'`
		APPVERDIR=${BASEDIR}/${PAPPNAME}/${APPVER}
		#printf '{"name":"%s","address":"http://gateway.%s/tenant/%s","appname":"%s","appver":"%s"' $P $OCPINGRESS $P $PAPPNAME $APPVER
		# http://tenant2-instance-tenant2. openshift-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud
		printf '{"name":"%s","address":"http://%s-instance-%s.%s","appname":"%s","appver":"%s"' $P $P $P $OCPINGRESS $PAPPNAME $APPVER
		if [[ .`cat ${APPVERDIR}/tenant.${P}.status 2>/dev/null | wc -c | xargs`. == .0. ]]; then
			printf ', "istat" : 0, "data" : ['
		else
			printf ', "istat" : 1, "data" : ['
		fi
		LOGFILE=${APPVERDIR}/tenant.${P}.log
		_formatArrayElem ${LOGFILE}
		printf ']}'
	fi
done
printf ']}'

exit 0
