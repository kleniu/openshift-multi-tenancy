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
STATUSFILE=${APPVERDIR}/tenant.${TENANTNAME}.status
ENVFILE=${APPVERDIR}/tenant.${TENANTNAME}.env

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
		printf '{ "status" : 1, "desc" : "Application %s is not installed. The directory %s does not exist.", "data" : []}' ${APPNAME} ${APPVERDIR}
		echo "error" > ${STATUSFILE}
		exit 1
	fi
	# check instantiated tenants
	if [[ .`ls ${APPVERDIR}/tenant.${TENANTNAME}.* | wc -l | xargs`. == .0. ]]; then
		printf '{ "status" : 2, "desc" : "Tenant %s is not instantiated.", "data" : []}' ${TENANTNAME}
		rm ${ENVFILE}
		echo "error" > ${STATUSFILE}
		exit 2
	fi
	# login to openshift cluster
	printf '#> oc login --token="<YOUR_SECRET_TOKEN>" --server="%s"\n' "${OCPSERVER}" >> ${LOGFILE} 2>&1
	oc login --token="${OCPTOKEN}" --server="${OCPSERVER}" >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 3, "desc" : "Cannot login to openshift cluster.", "data" : ['
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 3
	fi
	# checking if project associated with tenant already exists
	printf '## Checking if openshift project (namespace) "%s" exists.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	if [[ .`oc projects | awk '{ if ($1 == "*") { print $2 } else { print $1} }' | grep "^instance-${TENANTNAME}" | wc -l | xargs`. == .0. ]]; then
		printf '{"status" : 4, "desc" : "Tenant %s does not exist", "data" : []}' "${TENANTNAME}"
		echo "error" > ${STATUSFILE}
		exit 4
	else
		printf 'Openshift project (namespace) "%s" exists.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	
	fi
}

function postActions() {
	# creating the project associated with tenant
	printf '#> oc delete project "%s"\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	oc delete project "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 5, "desc" : "Cannot delete openshift project %s.", "data" : [' "instance-${TENANTNAME}"
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 5
	fi
}

printf "## Executing %s script\n" `basename ${0}` > ${LOGFILE}
printf "## %s\n" "`date`" >> ${LOGFILE}

prepareActions

printf '## BEGIN executing: deployment/isvconsole/uninstantiate.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
CURDIR=$PWD
cd ${APPVERDIR}/*/deployment/isvconsole/
source ./uninstantiate.sh ${PAPPNAME} ${APPVER} ${TENANTNAME} >> ${CURDIR}/${LOGFILE} 2>&1 
RETVAL=$?
cd $CURDIR
printf '## END executing: deployment/isvconsole/uninstantiate.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
if [[ .${RETVAL}. != .0. ]]; then
	echo "## Script deployment/isvconsole/uninstantiate.sh returned non zero exit code." >> ${LOGFILE} 2>&1
	printf '{ "status" : 6, "desc" : "Script deployment/isvconsole/instantiate.sh returned non zero exit code.", "data" : ['
	_formatArrayElem ${LOGFILE}
	printf ']}'
	echo "error" > ${STATUSFILE}
	exit 6
fi

postActions

printf "## %s\n" "`date`" >> ${LOGFILE}
printf "## Sucessfully executed script %s\n" `basename ${0}` >> ${LOGFILE}
printf '{ "status" : 0, "desc" : "Success", "data" : ['
_formatArrayElem ${LOGFILE}
printf ']}'

rm -f ${APPVERDIR}/tenant.${TENANTNAME}.* 2>/dev/null

exit 0