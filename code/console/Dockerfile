FROM centos:8
MAINTAINER Robert Kleniewski robert.kleniewski@pl.ibm.com

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
RUN npm install

EXPOSE 3000
CMD [ "npm", "start" ] 

