FROM centos:8
MAINTAINER Robert Kleniewski robert.kleniewski@pl.ibm.com

# update OS and install tools
RUN yum makecache
RUN yum upgrade -y
RUN yum install wget -y && yum install curl -y

# Replace shell with bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install nvm
COPY tools/nvm-install.sh /bin/. 
RUN chmod 700 /bin/nvm-install.sh \
    && /bin/nvm-install.sh 
RUN source /root/.bashrc \
    && nvm install stable

# install app
WORKDIR /app
COPY . .
RUN source /root/.bashrc && \
    npm install

# prepare start command
RUN chmod 700 /root/.nvm/nvm.sh && \
    echo "#!/bin/bash" > /bin/start.sh && \
    echo ". /root/.nvm/nvm.sh" >> /bin/start.sh && \
    echo "npm start" >> /bin/start.sh && \
    chmod 700 /bin/start.sh

EXPOSE 4000
CMD [ "start.sh" ]

