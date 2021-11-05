FROM ubuntu:20.04

LABEL maintainer="Daniel Bittman <danielbittman1@gmail.com>"

ENV DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles"

# Make sure the package repository is up to date.
#RUN apt-get update && \
#    apt-get -qy full-upgrade && \
#    apt-get install -qy git && \
# Install a basic SSH server
#    apt-get install -qy openssh-server && \
#    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
#    mkdir -p /var/run/sshd && \
#    apt-get install -qy openjdk-11-jdk && \
# Cleanup old packages
#    apt-get -qy autoremove && \
# Add user jenkins to the image
#    adduser --quiet jenkins && \
# Set password for the jenkins user (you may want to alter this).
#    echo "jenkins:jenkins" | chpasswd

# Copy authorized keys
#COPY authorized_keys /home/jenkins/.ssh/authorized_keys

#RUN chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
#EXPOSE 22

ARG VERSION=4.9
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (agent.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN apt-get update && apt-get -y install git-lfs curl openjdk-11-jdk && rm -rf /var/lib/apt/lists/*
RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

RUN apt-get update && apt-get -y install build-essential cmake xorriso mtools libtommath-dev libtomcrypt-dev ninja-build clang
RUN apt-get update && apt-get -y install python3.8 python3-distutils gcc-multilib zlib1g zlib1g-dev llvm llvm-dev grub2-common
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

RUN apt-get update && apt-get -y install rustc cargo

RUN apt-get update && apt-get -y install graphviz global doxygen


USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}


VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}

WORKDIR /home/${user}

