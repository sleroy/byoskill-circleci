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
    apt-get install -y --no-install-recommends \ 
    vim \ 
    curl ca-certificates \ 
    build-essential git unzip \ 
    gnupg2 \
    software-properties-common \
    openjdk-8-jdk-headless \ 
    python && \ 
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* 
 
RUN apt-get dist-upgrade -y
RUN curl -fsSL get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker root

RUN apt-get install -y apt-utils zip curl wget

RUN curl -L https://services.gradle.org/distributions/gradle-2.4-bin.zip -o gradle-2.4-bin.zip
RUN apt-get install -y unzip
RUN unzip gradle-2.4-bin.zip
ENV GRADLE_HOME=/app/gradle-2.4
ENV PATH=$PATH:$GRADLE_HOME/bin

# setup Google Cloud SDK 
ENV PATH=/work/google-cloud-sdk/bin:$PATH 
RUN curl -o google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-158.0.0-linux-x86_64.tar.gz && \
    tar -zxvf google-cloud-sdk.tar.gz && \
    rm google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh --quiet && \ 
    gcloud components update --quiet && \ 
    gcloud --quiet components install docker-credential-gcr kubectl 

# setup node.js environment 
ENV PATH=/root/.nodebrew/current/bin:$PATH 
RUN curl -L git.io/nodebrew | perl - setup && nodebrew install-binary ${NODEJS_VERSION} && nodebrew use ${NODEJS_VERSION} 

# setup openjdk environment 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64 
RUN java -version
