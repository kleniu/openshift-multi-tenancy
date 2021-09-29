set -e
set -x

case ${1} in
	1)
		PNAME=tenant1-demo
		PAPPCOLOR=green
		PAPPNAME="Tenant 1 App"	
		;; 
	2)
		PNAME=tenant2-demo
		PAPPCOLOR=red
		PAPPNAME="Tenant 2 App"	
		;; 
	3)
		PNAME=tenant3-demo
		PAPPCOLOR=blue
		PAPPNAME="Tenant 3 App"	
		;; 
	*) 	
		PNAME=app-demo
		PAPPCOLOR=purple
		PAPPNAME="Demo App"	
		;;
		
esac


oc new-project ${PNAME}
oc new-app --image-stream=webapp-boilerplate-build --name=${PNAME} -e APPCOLOR=${PAPPCOLOR} -e APPNAME="${PAPPNAME}" -n ${PNAME} 
oc expose svc/${PNAME}
