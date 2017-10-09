FROM alpine:3.6
MAINTAINER olly@docker.com

RUN apk add --upgrade --no-cache \
    ca-certificates \
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

# Copy Accross UCP Certs
COPY ucp-bundle-jenkins.zip /home/jenkins/
RUN (unzip /home/jenkins/ucp-bundle-jenkins.zip -d /home/jenkins/ && \
    cp /home/jenkins/ca.pem /usr/local/share/ca-certificates/ca.pem && \
    update-ca-certificates)

# Install the Docker Client
RUN (wget -O /tmp/docker-static.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-17.09.0-ce.tgz" &&\
  cd /tmp &&\
  tar -vxzf docker-static.tgz &&\
  mv /tmp/docker/docker /usr/local/bin/docker &&\
  chmod +x /usr/local/bin/docker &&\
  rm -rf /tmp/docker /tmp/docker-static.tgz)

# install notary
RUN (wget -O /usr/local/bin/notary "https://github.com/docker/notary/releases/download/v0.4.3/notary-Linux-amd64" &&\
  chmod +x /usr/local/bin/notary)

# Add user jenkins to the image
RUN (adduser -D -h /home/jenkins -s /bin/sh jenkins && \
    echo "jenkins:jenkins" | chpasswd && \
    chown -R jenkins:jenkins /home/jenkins/*)

# Expose SSH
EXPOSE 22

# Insert a Startup Script and Run it
ADD jenkins-slave-startup.sh /
CMD ["./jenkins-slave-startup.sh"]
