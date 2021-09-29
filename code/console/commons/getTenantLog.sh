#!/bin/bash
BASEDIR=$1
PAPPNAME=$2
APPVER=$3
TENANTNAME=$4
OCPTOKEN=$5
OCPSERVER=$6

# Do not change
APPVERDIR=${BASEDIR}/${PAPPNAME}/${APPVER}
LOGFILE=${APPVERDIR}/tenant.${TENANTNAME}.log

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
	# check app dir
	if [[ ! -d ${APPVERDIR} ]]; then
		printf '{ "status" : 1, "desc" : "Application %s is not installed. The directory %s does not exist.", "data" : {}}' ${APPNAME} ${APPVERDIR}
		exit 1
	fi
	# login to openshift cluster
	oc login --token="${OCPTOKEN}" --server="${OCPSERVER}" > /dev/null 2>&1
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 2, "desc" : "Cannot login to openshift cluster.", "data" : {}'
		exit 2
	fi
	# check if tenant is instantiated
	if [[ .`oc projects | awk '{ if ($1 == "*") { print $2 } else { print $1} }' | grep "^instance-${TENANTNAME}" | sed 's/^instance-//g'`. != .${TENANTNAME}. ]]; then
		printf '{ "status" : 3, "desc" : "Tenant %s has no associated project (namespace).", "data" : {} }' "${TENANTNAME}"
		exit 3
	fi
}

prepareActions

printf '{ "status" : 0, "desc" : "Success", "data" : {'
printf '"name":"%s"' $TENANTNAME
if [[ .`cat ${APPVERDIR}/tenant.${P}.status 2>/dev/null | wc -c | xargs`. == .0. ]]; then
	printf ', "istat" : 0, "data" : ['
else
	printf ', "istat" : 1, "data" : ['
fi

_formatArrayElem ${LOGFILE}
printf ']'
printf '}}'

exit 0