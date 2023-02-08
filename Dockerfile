FROM ubuntu:22.04

MAINTAINER BrownianMotion

ENV LC_ALL en_US.UTF-8 
RUN locale-gen en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LANG en_US.UTF-8  

ENV DEBIAN_FRONTEND noninteractive

### Install dependencies

RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y

RUN apt-get install -y \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    lib32gcc1 \
    libstdc++6 \
    curl \
    wget \
    bsdtar \
    build-essential

### Install Powershell

# Update the list of packages
RUN sudo apt-get update
# Install pre-requisite packages.
RUN sudo apt-get install -y wget apt-transport-https software-properties-common
# Download the Microsoft repository GPG keys
RUN wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
RUN sudo dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
RUN sudo apt-get update
# Install PowerShell
RUN sudo apt-get install -y powershell


### Set up the pieces of the server image

USER root

RUN mkdir -p /steamcmd
RUN mkdir -p /starbound
VOLUME ["/starbound"]
RUN cd /steamcmd \
	&& wget -o /tmp/steamcmd.tar.gz http://media.steampowered.com/installer/steamcmd_linux.tar.gz \
	&& tar zxvf steamcmd_linux.tar.gz \
	&& rm steamcmd_linux.tar.gz \
        && chmod +x ./steamcmd.sh


ADD start.ps1 /start.ps1

ADD update.ps1 /update.ps1

# Add initial require update flag
ADD .update /.update

WORKDIR /

EXPOSE 28015
EXPOSE 28016

ENV STEAM_LOGIN FALSE

ENV DEBIAN_FRONTEND newt

ENTRYPOINT ["./start.ps1"]
