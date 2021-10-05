#!/bin/bash
BASEDIR=$1
PAPPNAME=$2
APPVER=$3
OCPTOKEN=$4
OCPSERVER=$5

# do not change
CURDIR=$PWD

APPVERDIR=${BASEDIR}/${PAPPNAME}/${APPVER}
LOGFILE=${APPVERDIR}/appinstall.log
STATUSFILE=${APPVERDIR}/appinstall.status

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
	# check if renants are installed
	if [[ .`ls ${APPVERDIR}/tenant.* 2>/dev/null | wc -l | xargs`. != .0. ]]; then
		printf '{ "status" : 2, "desc" : "There are tenands using application %s . Delete tenants first.", "data" : []}' ${APPNAME} 
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
}
printf "## Executing %s script\n" `basename ${0}` > ${LOGFILE}
printf "## %s\n" "`date`" >> ${LOGFILE}

prepareActions

printf '## BEGIN executing: deployment/isvconsole/uninstall.sh %s %s \n' "${PAPPNAME}" "${APPVER}" >> ${LOGFILE}
CURDIR=$PWD
cd ${APPVERDIR}/*/deployment/isvconsole/
bash -c "./uninstall.sh ${PAPPNAME} ${APPVER}" >> ${CURDIR}/${LOGFILE} 2>&1 
RETVAL=$?
cd $CURDIR
printf '## END executing: deployment/isvconsole/uninstall.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" >> ${LOGFILE}
if [[ .${RETVAL}. != .0. ]]; then
	echo "## Script deployment/isvconsole/uninstall.sh returned non zero exit code." >> ${LOGFILE} 2>&1
	printf '{ "status" : 4, "desc" : "Script deployment/isvconsole/install.sh returned non zero exit code.", "data" : ['
	_formatArrayElem ${LOGFILE}
	printf ']}'
	echo "error" > ${STATUSFILE}
	exit 4

fi
printf "## %s\n" "`date`" >> ${LOGFILE}
printf "## Sucessfully executed script %s\n" `basename ${0}` >> ${LOGFILE}
printf '{ "status" : 0, "desc" : "Success", "data" : ['
_formatArrayElem ${LOGFILE}
printf ']}'
printf '' > ${STATUSFILE}
## dangerous!
rm -rf ${APPVERDIR}
if [[ .`ls ${BASEDIR}/${PAPPNAME}`. == .. ]]; then
	rmdir ${BASEDIR}/${PAPPNAME}
fi

exit 0



