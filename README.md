# Openshift multi-tenancy web apps.
On this page you will find a quick description of the project. If you are interested, drop me a message and create a few lines of code. I confess that sharing this prototype was a lot of fun for me, so I believe you can have fun writing the code as well.

## What is the project about
Talking to a few of some ISVs, I came to the conclusion that every software producer that has been on the market for a longer time would like to make their apps available in the SaaS model. In particular, it is interesting for ISVs to enable payment for the use of their software in the pay-as-you-go model. Usually, the software that has already been created by ISVs does not support this model of billing end customers (tenants). To implement the pay-as-you-go, it would usually require quite large changes in code. However, I believe it is possible if you use the right tools. This project can be such a tool.

## Why did I launch this project
I started this project as a kind of PoC, so I do not recommend using it in production. At this stage, I did a lot of shortcuts in the code.

But to the point. I wanted to show how legasy contenerised web applications can be made available in SaaS model, so that end users (tenants) can settle with ISVs in the pay-as-you-go model for the actual app usage not for a perpetural licence.

## What goals do I want to achieve
First of all, meeting the following expectations of ISV:

* Providing the possibility of billing in the pay-as-you-go model for legacy web applications usage.

Most of the web applications provided by ISVs are already containerized. Unfortunately, calculating the costs of using such an application, even if it is delivered from the cloud, requires significant changes in the code.

* Logical separation of individual tenants

Most ISVs pointed to the fact that the separation of tenants who use the application should be as deep as possible. However, for cost reasons, it should not reach the level of physical hardware separation (e.g. application components run on dedicated hardware). In other words, it should not be acceptable to share running processes of the app, but it is perfectly possible to share code of the app and hardware it uses.

* The tool provided must be simple and flexible

The provided tool for onboarding new tenants should be as easy to use as possible, but at the same time very flexible, so that it does not require changes in the code of applications to be used by tenants.

* Allow tenants to use additional services provided by ISV (e.g. authentication)

some tenants may not want to maintain a users authentication/autorisation and all components required to protect sensitive personal data. ISV can do it for the tenant, guaranteeing compliance with legal regulations (like GDPR). ISV can provide appropriate tools, processes and personnel (personal data processor).

## How can these challenges be addressed

See Architecture Overview Diagram

## Quick Start

**ISV Console App.**

The sample code is located in `code/console` directory.

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

## Documentation

The documentation will be available [HERE](https://kleniu.github.io/openshift-multi-tenancy/) SOON

## How to contribute to the project
Drop me a message via [LinkedIn](https://www.linkedin.com/in/robert-kleniewski-8563241/). I will be delighted to to meet you there!

## Important info - please read
The code I put here is a product of few hours of work in speed coding mode. This means that I made a few shortcuts, if not a dozen or so that certainly would not be liked by security auditors, and even regular developers. My goal was to show an idea that was born in my head, not to create a commercial product.
I would like the project code to be available for procution deployments. I'd love to get rid of the shortcuts and made the code ready for production. Going to be fun.

Please do not use the code to harm Humans or animals !!! :) 