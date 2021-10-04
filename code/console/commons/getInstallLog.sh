#!/bin/bash
BASEDIR=$1
PAPPNAME=$2
APPVER=$3

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

function prepareActions() {
	# check app dir
	if [[ ! -d ${APPVERDIR} ]]; then
		printf '{ "status" : 1, "desc" : "Application %s is not installed. The directory %s does not exist.", "data" : {}}' ${APPNAME} ${APPVERDIR}
		exit 1
	fi
}

prepareActions


STATUS=`cat ${STATUSFILE} 2>/dev/null | head -1 | xargs`
printf '{ "status" : 0, "desc" : "Success", "data" : { '
printf '"aname":"%s", "aver":"%s"' $PAPPNAME $APPVER

case ${STATUS} in
	OK)
		printf ', "istat" : "OK", "data" : ['
		;;
	error) 
		printf ', "istat" : "ERR", "data" : ['
		;;
	installing)
		printf ', "istat" : "INS", "data" : ['
		;;
	*)
		printf ', "istat" : "unknown", "data" : ['
		;;
esac

_formatArrayElem ${LOGFILE}
printf ']'
printf '}}'


exit 0
