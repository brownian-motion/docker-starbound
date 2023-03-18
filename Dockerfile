FROM ubuntu:22.04 as base
# FROM steamcmd/steamcmd:ubuntu as base

MAINTAINER BrownianMotion


### Install dependencies

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y

### set environment

ENV LC_ALL en_US.UTF-8 
RUN apt-get install -y locales && locale-gen en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LANG en_US.UTF-8  

ENV DEBIAN_FRONTEND noninteractive

### get dependencies for scripts and build

# dependencies for steamcmd.sh AND add-apt-repository
RUN apt-get install -y \
    ca-certificates \
    software-properties-common \
    libstdc++6 \
    curl \
    wget \
    dpkg \
    build-essential
# required if on 64-bit machine
RUN add-apt-repository multiverse 
RUN dpkg --add-architecture i386
RUN apt update
# dependencies for steamcmd.sh
# RUN apt-get install -y \
#     python-software-properties \
#     lib32gcc1-s1 \
#     bsdtar 
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections
RUN apt-get install -y steamcmd

### Install Powershell

# Update the list of packages
RUN apt-get update
# Install pre-requisite packages.
RUN apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
RUN dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
RUN apt-get update
# Install PowerShell
RUN apt-get install -y powershell


### Set up the pieces of the server image

USER root

RUN mkdir -p /steamcmd
RUN mkdir -p /starbound
VOLUME ["/starbound"]
# RUN cd /steamcmd \
# 	&& wget -o /tmp/steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
# 	&& tar zxvf steamcmd_linux.tar.gz \
# 	&& rm steamcmd_linux.tar.gz \
#     && chmod +x ./steamcmd.sh


ADD start.ps1 /start.ps1
ADD update.ps1 /update.ps1
ADD lib.psm1 /lib/lib.psm1

WORKDIR /

ENV STEAM_LOGIN FALSE

ENV DEBIAN_FRONTEND newt

FROM base as test
RUN ["/usr/bin/env", "pwsh", "-c", "Install-Module -Name Pester -Force"]

ADD test.ps1 /test.ps1
COPY tests/ /tests/

ENTRYPOINT ["/usr/bin/env", "pwsh"]
RUN ["./test.ps1"]

FROM base as main

EXPOSE 28015
EXPOSE 28016

ENTRYPOINT ["./start.ps1"]
