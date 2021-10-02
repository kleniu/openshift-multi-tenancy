#!/bin/bash

ISVNAME='isv'

echo "##### Starting deployment script at" `date`

function check_envvars() {
    # OCPTOKEN OCPSERVER OCPINGRESS
    if [[ .`echo ${OCPTOKEN}`. == .. || .`echo ${OCPSERVER}`. == .. ]]; then 
        echo "## Required variable OCPTOKEN or OCPSERVER is unset or it's empty." 
        echo "## Follow the instructions available on page: https://ibm-developer.gitbook.io/openshift101/resources/setup_cli"
        echo "## to get your API token and serwer URL address."
        echo "## The API token (OCPTOKEN) is the string 51 characters long and looks like this: sha256~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
        echo "## The Server address (OCPSERVER) is the URL address profided in --server parameter of 'oc login' command"
        echo "## Set OCPTOKEN to your API token and OCPSERVER to your openshift API address first."
        echo "## Exiting."
        exit 1
    fi
    if [[ .`echo ${OCPINGRESS}`. == .. ]]; then 
        echo "## You are almost ready to go. The last required variable OCPINGRESS is unset or it's empty."
        echo "## Login to your IBM Cloud account and click on your up and running Openshift service."
        echo "## On the 'Overview' page find the 'Networking' section and grab the 'Ingress subdomain' address."
        echo "## The 'Ingress subdomain' default value looks like this: openshift-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud" 
        echo "## Set OCPINGRESS variable to your 'Ingress subdomain' associated with your Openshift cluster first."
        echo "## Exiting."
        exit 1
    fi
    echo "## ALl required env variables are set."
}

function check_tooling() {
    # ibmcloud, ibmcloud plugin list, oc version --client
    echo "## IBM Cloud cli version:"
    ibmcloud version 2>&1
    if [[ .$?. != .0. ]]; then
        echo "## ibmcloud cli is not installed or it is not included in \$PATH."
        echo "## Folow the instructions on https://www.ibm.com/cloud/cli to instal it."
        echo "## Exiting."
        exit 2
    fi
    echo "## Openshift cli version:"
    oc version --client 2>&1
    if [[ .$?. != .0. ]]; then
        echo "## Openshift cli is not installed or it is not on included in \$PATH."
        echo "## Folow the instructions on https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html to instal it."
        echo "## Exiting."
        exit 2
    fi
}

function check_setup() {
    echo "## Loging in to your Openshift cluster."
    oc login --token=${OCPTOKEN} --server=${OCPSERVER}
    if [[ .$?. != .0. ]]; then
        echo "## I cannot login to your cluster using following command:"
        echo "## oc login --token=${OCPTOKEN} --server=${OCPSERVER}"
        echo "## Check your variables and Openshift cluster status."
        echo "## Exiting."
        exit 3
    fi
    echo "## Login to Openshift cluster sucessuly finished. Good!"
}

function check_local_build() {
    docker build -t console:latest -f ../code/console/Dockerfile ../code/console
    if [[ .$?. != .0. ]]; then
        echo "## I cannot build the image for application 'console' using local Docker env."
        echo "## Exiting."
        exit 4
    fi
    docker run --name console -e OCPTOKEN=${OCPTOKEN} -e OCPSERVER=${OCPSERVER} -e OCPINGRESS=${OCPINGRESS} -p 3000:3000 -d console
    if [[ .$?. != .0. ]]; then
        echo "## I cannot instantiate image for application 'console' using local Docker env."
        echo "## Exiting."
        exit 5
    fi
}

function openshift_deploy_build() {
    
    echo "## Creating ${ISVNAME} project in openshift"
    if [[ .`oc get projects | grep ${ISVNAME} | wc -l | xargs`. != .0. ]]; then 
        oc delete project ${ISVNAME}
        while [[ .`oc get projects | grep ${ISVNAME} | wc -l | xargs`. != .0. ]]; do
            sleep 1; printf '.'
        done
        printf '\n' 
    fi
    oc new-project ${ISVNAME}
    while [[ .`oc get projects | grep "${ISVNAME}" | grep 'Active' | wc -l | xargs`. == .0. ]]; do
            sleep 1; printf '.'
    done
    
    ID=console
    if [[ .`oc get buildconfigs -n openshift | grep ${ID}-build`. != .. ]]; then
        echo "## I: build config ${ID}-build exists. Skipping creation."
    else
        echo "#> oc new-build --strategy docker --name=${ID}-build  --binary=true -n openshift"
        oc new-build --strategy docker --name=${ID}-build  --binary=true -n openshift
        if [[ .$?. != .0. ]]; then
            echo "## E: Cannot create new build ${ID}-build"
            exit 6
        fi
    fi

    echo "#> oc start-build ${ID}-build --from-dir='../code/console/' --follow -n openshift"
    oc start-build ${ID}-build --from-dir='../code/console/' --follow -n openshift
    if [[ .$?. != .0. ]]; then
        echo "## E: Cannot start build ${ID}-build"
        exit 7
    fi

    oc new-app --image-stream=${ID}-build --name='console' -e OCPTOKEN=${OCPTOKEN} -e OCPSERVER="${OCPSERVER}" -e OCPINGRESS="${OCPINGRESS}" 
    if [[ .$?. != .0. ]]; then
        echo "## E: Cannot create app: 'console' using iname-stream: ${ID}-build"
        exit 8
    fi
    oc expose svc/console
    if [[ .$?. != .0. ]]; then
        echo "## E: Cannot expose app: 'console'"
        exit 9
    fi

    echo "## Success!!!"
    echo "## Your console is available at: http://console-isv.${OCPINGRESS}" 
}

echo "### Cheking if required tools are installed."
check_tooling
echo "### Checking if the required environment variables are set."
check_envvars
echo "### Checking your Openshift cluster environemnt."
check_setup
#echo "### Checking if docker image for application 'console' can be built successfully."
#check_local_build
echo "### Deploing to Openshift"
openshift_deploy_build