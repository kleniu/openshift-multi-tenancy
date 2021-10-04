#!/bin/bash

BASEDIR=$1

printf '{ "status" : 0, "desc" : "Success", "data" : ['
_FIRST=true
for P in `find $BASEDIR/* -maxdepth 1 -mindepth 1`; do 
	if [[ .$_FIRST. == .true. ]]; then
		_FIRST=false
	else
		printf ','
	fi
	APATH=`echo $P | sed "s#^${BASEDIR}/##g"`
	ANAME=`echo $APATH | awk -F '/' '{ print $1 }'`
	AVER=`echo $APATH | awk -F '/' '{ print $2 }'`
	ASIZE=`du -sk $P | awk '{print $1}'`
	if [[ -f ${P}/appinstall.status ]]; then
		STATUS=`cat ${P}/appinstall.status 2>/dev/null | head -1 | xargs`
		case ${STATUS} in
			OK)
				AISTAT="OK"
				;;
			error) 
				AISTAT="ERR"
				;;
			installing)
				AISTAT="INS"
				;;
			*)
				AISTAT="unknown"
				;;
		esac
	else
		AISTAT="unknown"
	fi
	printf '{"aname":"%s","aver":"%s","asize":%d,"apath":"%s","aistat":"%s"}' $ANAME $AVER $ASIZE $APATH $AISTAT

done
printf ']}'
