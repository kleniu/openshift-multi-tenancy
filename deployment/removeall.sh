#!/bin/bash

ISVNAME='isv'

echo "##### Starting cleanup script at" `date`

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

function remove_local_build() {
    docker rm -f console
    if [[ .$?. != .0. ]]; then
        echo "## I cannot delete local container 'console' using local Docker env."
        echo "## Exiting."
        exit 4
    fi
    docker rmi console:latest 
    if [[ .$?. != .0. ]]; then
        echo "## I cannot delete local image for application 'console' using local Docker env."
        echo "## Exiting."
        exit 5
    fi
}

function remove_openshift_build() {
    for P in `oc get projects | grep "^instance-" | awk '{print $1}'`; do 
        echo "## removing namespace ${P}"
        oc delete project $P
        while [[ .`oc get projects | grep $P | awk '{print $1}' | wc -l | xargs`. != .0. ]]; do
            sleep 1; printf '.'
        done
        printf '\n'
    done

    oc delete project ${ISVNAME}
    while [[ .`oc get projects | grep "^${ISV}$" | awk '{print $1}' | wc -l | xargs`. != .0. ]]; do
            sleep 1; printf '.'
    done
    printf '\n'
    
    for P in `oc get builds -n openshift | grep -e '-build-[0-9]' | awk '{print $1}' | xargs`; do 
        echo "## removing build: ${P}"
        oc delete build $P -n openshift
    done

    for P in `oc get buildconfigs -n openshift | awk '{print $1}' | grep -e '-build$' | xargs`; do 
        echo "## removing build config: ${P}"
        oc delete buildconfig $P -n openshift
    done 
    
}


echo "### Cheking if required tools are installed."
check_tooling
echo "### Checking if the required environment variables are set."
check_envvars
echo "### Checking your Openshift cluster environemnt."
check_setup
#echo "### Deleting local docker image for application 'console'."
#remove_local_build
echo "### Deleteing Openshift namespaces and images"
remove_openshift_build 