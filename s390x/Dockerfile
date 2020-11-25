FROM quay.io/ibmz/golang:1.14
# Install docker
# List of keyservers to search for keys from
ENV SERVERS \
        "ha.pool.sks-keyservers.net" \
        "hkp://p80.pool.sks-keyservers.net:80" \
        "pgp.mit.edu"
RUN apt-get update && apt-get install -y curl gnupg
RUN apt-get install -y software-properties-common 
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg > Docker.key
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Docker.gpg add Docker.key
RUN rm Docker.key
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository \
   "deb [arch=s390x] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

ENV DOCKER_VERSION=18.06.0
RUN apt-get install -y git docker-ce=${DOCKER_VERSION}~ce~3-0~ubuntu 
RUN apt-get install -y make dumb-init
RUN  git clone https://github.com/arminc/clair-scanner.git && cd clair-scanner && make installLocal
ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/go/bin/clair-scanner" ]
