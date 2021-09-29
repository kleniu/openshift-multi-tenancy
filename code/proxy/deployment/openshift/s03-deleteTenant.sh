set -x
set -e

case ${1} in
	1)
		PNAME=tenant1-demo
		;;
	2)
		PNAME=tenant2-demo
		;;
	3)
		PNAME=tenant3-demo
		;;
	*)
		PNAME=app-demo
		;;
esac

oc delete project ${PNAME}
