#!/bin/bash
BASEDIR=$1
PAPPNAME=$2
APPVER=$3
TENANTNAME=$4
OCPTOKEN=$5
OCPSERVER=$6
EVARB64=$7

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
		printf 'Application %s is not installed. The directory %s does not exist.\n' ${APPNAME} ${APPVERDIR} >> ${LOGFILE} 2>&1
		printf '{ "status" : 1, "desc" : "Application %s is not installed. The directory %s does not exist.", "data" : []}' ${APPNAME} ${APPVERDIR}
		echo "error" > ${STATUSFILE}
		exit 1
	fi
	# check env var encoding
	echo ${EVARB64} | base64 -d > ${ENVFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf 'Cannot decode env vars list. Base64 string : %s \n' "${EVARB64}" >> ${LOGFILE} 2>&1
		printf '{ "status" : 2, "desc" : "Cannot decode env vars list. Base64 string : %s", "data" : []}' ${EVARB64}
		rm ${ENVFILE}
		echo "error" > ${STATUSFILE}
		exit 2
	fi
	# check and source envvar script
	printf '#> source %s\n' "${ENVFILE}" >> ${LOGFILE} 2>&1
	source ${ENVFILE} >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf 'Wrong env vars list format.\n' >> ${LOGFILE} 2>&1
		printf '{ "status" : 3, "desc" : "Wrong env vars list format.", "data" : ['
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 3
	fi
	# login to openshift cluster
	printf '#> oc login --token="<YOUR_SECRET_TOKEN>" --server="%s"\n' "${OCPSERVER}" >> ${LOGFILE} 2>&1
	oc login --token="${OCPTOKEN}" --server="${OCPSERVER}" >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf 'Cannot login to openshift cluster.\n' >> ${LOGFILE} 2>&1
		printf '{ "status" : 4, "desc" : "Cannot login to openshift cluster.", "data" : ['
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 4
	fi
	# checking if project associated with tenant already exists
	printf '## Checking if openshift project (namespace) "%s" already exists.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	if [[ .`oc get projects | grep Active | awk '{ if ($1 == "*") { print $2 } else { print $1} }' | grep "^instance-${TENANTNAME}" | wc -l | xargs`. != .0. ]]; then
		printf 'Project (namespace) "%s" already exist.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
		printf '{"status" : 5, "desc" : "Tenant %s already exist", "data" : []}' "${TENANTNAME}"
		echo "error" > ${STATUSFILE}
		exit 5
	else
		printf 'Openshift project (namespace) "%s" has not been created yet. Ready to create one.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
	fi
	# creating the project associated with tenant
	printf '#> oc new-project "%s" --display-name="%s" --description="%s"\n' "instance-${TENANTNAME}" "${TENANTNAME}" "Instance of ${PAPPNAME} application for tenant ${TENANTNAME}" >> ${LOGFILE} 2>&1
	oc new-project "instance-${TENANTNAME}" --display-name="${TENANTNAME}" --description="Instance of ${PAPPNAME} application for tenant ${TENANTNAME}" >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf 'Cannot create openshift project %s.\n' "instance-${TENANTNAME}" >> ${LOGFILE} 2>&1
		printf '{ "status" : 6, "desc" : "Cannot create openshift project %s.", "data" : [' "instance-${TENANTNAME}"
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 6
	fi
}

printf "## Executing %s script\n" `basename ${0}` > ${LOGFILE}
printf "## %s\n" "`date`" >> ${LOGFILE}
echo "instantiating" > ${STATUSFILE}

prepareActions

printf '## BEGIN executing: deployment/isvconsole/instantiate.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
CURDIR=$PWD
cd ${APPVERDIR}/*/deployment/isvconsole/
source ./instantiate.sh ${PAPPNAME} ${APPVER} ${TENANTNAME} >> ${CURDIR}/${LOGFILE} 2>&1 
RETVAL=$?
cd $CURDIR
printf '## END executing: deployment/isvconsole/instantiate.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
if [[ .${RETVAL}. != .0. ]]; then
	echo "## Script deployment/isvconsole/instantiate.sh returned non zero exit code." >> ${LOGFILE} 2>&1
	printf '{ "status" : 7, "desc" : "Script deployment/isvconsole/instantiate.sh returned non zero exit code.", "data" : ['
	_formatArrayElem ${LOGFILE}
	printf ']}'
	echo "error" > ${STATUSFILE}
	exit 7

fi

printf "## %s\n" "`date`" >> ${LOGFILE}
printf "## Sucessfully executed script %s\n" `basename ${0}` >> ${LOGFILE}
printf '{ "status" : 0, "desc" : "Success", "data" : ['
_formatArrayElem ${LOGFILE}
printf ']}'
printf 'OK' > ${STATUSFILE}
exit 0

