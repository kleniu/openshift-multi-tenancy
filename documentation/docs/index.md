# Welcome to Openshift multi-tenancy web apps.

# Quick start
1) Export required environmental variables
```
export OCPTOKEN='<your_OCP_token_used_to_login_to_Openshift_cluster'
export OCPSERVER='<your_OCP_server_address'
export OCPINGRESS='<your_OCP_ingress_address>
``` 
*Here you can find instructions how to get these values*

*OCPTOKEN* and *OCPSERVER* - Follow the instructions available on page: https://ibm-developer.gitbook.io/openshift101/resources/setup_cli to get your API token and serwer URL address. The API token (OCPTOKEN) is the string 51 characters long and looks like this: sha256~XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX . The Server address (OCPSERVER) is the URL address profided in --server parameter of the 'oc login' command"

*OCPINGRESS* - Login to your IBM Cloud account and click on your up and running Openshift service. On the 'Overview' page find the 'Networking' section and grab the 'Ingress subdomain' address. The 'Ingress subdomain' default value - looks like this: openshift-070d31d9cf0761a13fcebd4a97861c1a-0000.eu-de.containers.appdomain.cloud"

2) Start the ISV Console application in the Openshift cluster
```
cd deployment/
./deployment.sh
```

if you want to remove pods, namespaces and all other artifacts created by `deployment.sh` script then run `removeall.sh` script.

## Architecture
coming soon

## Use cases
coming soon

## Technology used
coming soon

## Project directory layout

    code/
        console/  # NodeJS Express web app for ISV admin.
        proxy/    # NodeJS http reverse proxy (work in progress)
    deployment/
        deployall.sh    # Trivial openshift deployment script.
        removeall.sh    # Cleanup script.
    documentation/      
