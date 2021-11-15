FROM centos:8
LABEL version="1.0" maintainer="Robert Kleniewski robert.kleniewski@pl.ibm.com"

# update OS and install tools
RUN yum makecache
RUN yum upgrade -y
RUN yum install wget -y && yum install curl -y

# install dev env
RUN yum install git -y && \
    yum install nodejs -y

# Replace shell with bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install other tools like oc 
COPY deployment/docker/bins/oc /bin/. 

# create image for console app
WORKDIR /app
COPY . .
ENV KUBECONFIG=/app/apps/.kube/config
RUN mkdir -p /app/apps/.kube && chmod -R 777 /app/apps && npm install

EXPOSE 3000
CMD [ "npm", "start" ] 
###
