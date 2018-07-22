
FROM alpine:3.7
LABEL MAINTAINER=olly@docker.com

ARG UCPURL="https://ucp.olly.dtcntr.net:8443"
ARG NTYURL="https://github.com/theupdateframework/notary/releases/download/v0.4.3/notary-Linux-amd64"

RUN apk add --upgrade --no-cache \
    ca-certificates \
    curl \
    openssh \
    openssh-server \
    git \
    bash \
    sudo \
    wget && \
    rm -rf /var/cache/apk/*

# Configure Java 8
ENV JAVA_HOME /usr/lib/jvm/default-jvm
RUN apk add --no-cache openjdk8 && \
    ln -sf "${JAVA_HOME}/bin/"* "/usr/bin/"

# Embed UCP CA Certificate
RUN (curl -sk ${UCPURL}/ca > /usr/local/share/ca-certificates/ca.crt && \
    update-ca-certificates)

# Install the Docker Client
RUN (wget -q --no-check-certificate ${UCPURL}/linux/docker &&\
  mv docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker)

# Install notary
RUN (wget -q -O /usr/local/bin/notary ${NTYURL} &&\
  chmod +x /usr/local/bin/notary)

# Add user jenkins to the image
RUN (adduser -D -h /home/jenkins -s /bin/sh jenkins && \
    addgroup jenkins ping && \
    echo "jenkins:jenkins" | chpasswd && \
    chown -R jenkins:jenkins /home/jenkins)

# Expose SSH
EXPOSE 22

# Insert a Startup Script and Run it
ADD jenkins-slave-startup.sh /
CMD ["chmod +x /jenkins-slave-startup.sh && bash /jenkins-slave-startup.sh"]
