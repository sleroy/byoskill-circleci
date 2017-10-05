# docker build -t sylvainleroy/byoskill-circleci:0.1 .
#  docker build -t sylvainleroy/byoskill-circleci:0.1 .
# docker build -t us.gcr.io/byoskill-178715/circleci:0.1

FROM debian:stretch
MAINTAINER sleroy <sleroy0@gmail.com> 

# GKE build & testing environment for Circle CI 2.0 

USER root
ENV NODEJS_VERSION v8 
ENV DOCKER_VERSION 17.05.0-ce 

RUN mkdir /work 
WORKDIR /work 

RUN apt-get update && \ 
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \ 
    vim \ 
    curl ca-certificates \ 
    build-essential git unzip \ 
    gnupg2 \
    software-properties-common \
    openjdk-8-jdk-headless \ 
    apt-utils \
    git \
    ssh \
    zip \
    curl \
    wget \
    unzip \
    python && \ 
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* 

# Installation Docker

RUN curl -fsSL get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker root

# Download Gradle
RUN curl -L https://services.gradle.org/distributions/gradle-2.4-bin.zip -o gradle-2.4-bin.zip
RUN unzip gradle-2.4-bin.zip

# Download GCloud
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz && \
    tar -zxvf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet

ENV PATH=/work/google-cloud-sdk/bin:/root/.nodebrew/current/bin:$GRADLE_HOME/bin:$PATH 
RUN gcloud components update --quiet
RUN gcloud --quiet components install docker-credential-gcr kubectl 

# Downlod node.js
RUN curl -L git.io/nodebrew | perl - setup && nodebrew install-binary ${NODEJS_VERSION} && nodebrew use ${NODEJS_VERSION} 

# Env variables

ENV GRADLE_HOME=/work/gradle-2.4

# setup PATH
ENV PATH=/work/google-cloud-sdk/bin:/root/.nodebrew/current/bin:$GRADLE_HOME/bin:$PATH 
# setup openjdk environment 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64 
RUN echo "export PATH=/work/google-cloud-sdk/bin:/root/.nodebrew/current/bin:$GRADLE_HOME/bin:$PATH" >> /root/.bashrc
RUN java -version
RUN gradle -v

