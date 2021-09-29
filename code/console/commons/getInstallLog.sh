#!/bin/bash
BASEDIR=$1
APPNAME=$2
APPVER=$3

function formatOutput() {
	printf '{ "status" : 0, "desc" : "Success", "data" : ['
	_FIRST=true
	while read -r LINE; do
		if [[ .$_FIRST. == .true. ]]; then
			_FIRST=false
		else
			printf ','
		fi
		NOCH=`echo ${LINE} | sed "s/\"/\'/g"`
		printf '"%s"' "${NOCH}"
	done < appinstall.log 
	printf ']}'
}


if [[ ! -d ${BASEDIR}/${APPNAME}/${APPVER} ]]; then
	printf '{ "status" : 1, "desc" : "Application %s version %s is NOT installed. Install it first.", "data" : []}' "${APPNAME}" "${APPVER}"
else
	cd ${BASEDIR}/${APPNAME}/${APPVER}
	formatOutput
fi
