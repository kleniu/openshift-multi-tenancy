set -e
set -x

oc new-build --strategy docker --name=webapp-boilerplate-build  --binary=true -n openshift
oc start-build webapp-boilerplate-build --from-dir="../../" --follow -n openshift

