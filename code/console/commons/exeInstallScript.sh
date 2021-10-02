#!/bin/bash
BASEDIR=$1
PAPPNAME=$2
APPVER=$3
APPGITREPO=$4
OCPTOKEN=$5
OCPSERVER=$6

# Do not change
APPVERDIR=${BASEDIR}/${PAPPNAME}/${APPVER}
LOGFILE=${APPVERDIR}/appinstall.log
STATUSFILE=${APPVERDIR}/appinstall.status


function _formatArrayElem() {
	FILENAME=$1
	FIRST=true
	if [[ -f ${FILENAME} ]]; then
		while read -r LINE; do 
			NOCH=`echo ${LINE} | sed "s/\"/\'/g"`
			if [[ .${FIRST}. == .true. ]]; then
				FIRST=false
			else
				if [[ .${NOCH}. != .. ]]; then printf ', '; fi
			fi
			if [[ .${NOCH}. != .. ]]; then printf '"%s"' "${NOCH}"; fi
		done < ${FILENAME}
	fi
}

function makedirs() {
	# check app dir
	if [[ -d ${APPVERDIR} ]]; then
		printf '{ "status" : 1, "desc" : "Application %s is already installed. The directory %s exist.", "data" : []}' ${PAPPNAME} ${APPVERDIR}
		exit 1
	fi
	RES=`mkdir -p ${APPVERDIR}`
	printf '#> mkdir -p %s \n' ${APPVERDIR} >> ${LOGFILE} 2>&1
	echo ${RES} >> ${LOGFILE} 2>&1
}


function prepareActions() {
	# check if we are using git repo adress based on https - not the ssh
	if [[ ! ${APPGITREPO} =~ ^https* ]]; then
		echo "Use https address for git repo ${APPGITREPO}" >> ${LOGFILE}
		printf '{ "status" : 2, "desc" : "Use https address for git repo %s.", "data" : [] }' ${APPGITREPO}
		echo "error" > ${STATUSFILE}
		exit 2
	fi
	# clone git repo 
	CURDIR=$PWD
	printf '#> cd %s \n' ${APPVERDIR} >> ${LOGFILE} 2>&1
	cd ${APPVERDIR} >> ${LOGFILE} 2>&1
	printf '#> git clone --verbose %s \n' ${APPGITREPO} >> ${CURDIR}/${LOGFILE} 2>&1 
	git clone --verbose ${APPGITREPO} >> ${CURDIR}/${LOGFILE} 2>&1 
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 3, "desc" : "Cannot clone git repo %s.", "data" : [' ${APPGITREPO}
		_formatArrayElem ${CURDIR}/${LOGFILE}
		printf ']}'
		echo "error" > ${CURDIR}/${STATUSFILE}
		exit 3
	fi
	cd $CURDIR
	# login to openshift cluster
	printf '#> oc login --token="<YOUR_SECRET_TOKEN>" --server="%s"\n' "${OCPSERVER}" >> ${LOGFILE} 2>&1
	oc login --token="${OCPTOKEN}" --server="${OCPSERVER}" >> ${LOGFILE} 2>&1
	if [[ .$?. != .0. ]]; then
		printf '{ "status" : 4, "desc" : "Cannot login to openshift cluster.", "data" : ['
		_formatArrayElem ${LOGFILE}
		printf ']}'
		echo "error" > ${STATUSFILE}
		exit 4
	fi
}

makedirs

printf "## Executing %s script\n" `basename ${0}` > ${LOGFILE}
printf "## %s\n" "`date`" >> ${LOGFILE}

prepareActions


printf '## BEGIN executing: deployment/isvconsole/install.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
CURDIR=$PWD
cd ${APPVERDIR}/*/deployment/isvconsole/
bash -c "./install.sh ${PAPPNAME} ${APPVER} ${APPGITREPO}" >> ${CURDIR}/${LOGFILE} 2>&1 
RETVAL=$?
cd $CURDIR
printf '## END executing: deployment/isvconsole/install.sh %s %s %s \n' "${PAPPNAME}" "${APPVER}" "${TENANTNAME}" >> ${LOGFILE}
if [[ .${RETVAL}. != .0. ]]; then
	echo "## Script deployment/isvconsole/install.sh returned non zero exit code." >> ${LOGFILE} 2>&1
	printf '{ "status" : 5, "desc" : "Script deployment/isvconsole/install.sh returned non zero exit code.", "data" : ['
	_formatArrayElem ${LOGFILE}
	printf ']}'
	echo "error" > ${STATUSFILE}
	exit 5

fi

printf "## %s\n" "`date`" >> ${LOGFILE}
printf "## Sucessfully executed script %s\n" `basename ${0}` >> ${LOGFILE}
printf '{ "status" : 0, "desc" : "Success", "data" : ['
_formatArrayElem ${LOGFILE}
printf ']}'
printf '' > ${STATUSFILE}

exit 0