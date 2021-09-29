1. Create a new build by specifying source code
Create new __build config__ for creating the Docker image (__--startegy__) from local filesystem (__--binary=true__) in project (__-n__) **openshift**
I use **openshift** namespace because it is available for all other new projects (__namespaces__)
```
oc new-build --strategy docker --name=webapp-boilerplate-build  --binary=true -n openshift
```

2. Make image in `openshift` image repository
use local directory with the sourcecode (__--from-dir__) and follow (__--follow__) to see output from the build process. 
```
oc start-build webapp-boilerplate-build --from-dir="../../" --follow -n openshift
```

3. Start new application in namespace __tenant1-demo__
Create project
```
oc new-project tenant1-demo
```
create app using new image
```
oc new-app --image-stream=webapp-boilerplate-build --name=tenant1-demo -e APPCOLOR=green -e APPNAME="Tenant1 App" -n tenant1-demo
oc expose svc/tenant1-demo
```