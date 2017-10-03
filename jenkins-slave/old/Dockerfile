FROM evarga/jenkins-slave
MAINTAINER ollypom

ENV DEBIAN_FRONTEND noninteractive

# Adapted from: https://registry.hub.docker.com/u/jpetazzo/dind/dockerfile/
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    git \
    iptables \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Add the CA containing my UCP certificates into the Ubuntu Container
COPY ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN chmod +r /etc/ssl/certs/ca-certificates.crt

# Install the latest Docker Engine
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce && rm -rf /var/lib/apt/lists/*

ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
VOLUME /var/lib/docker

# Add UCP Credentials
ADD ucp-bundle-admin.zip /
RUN cd / && unzip ucp-bundle-admin.zip
RUN chown jenkins:jenkins /ca.pem /cert.pem /key.pem /cert.pub

# Make sure that the "jenkins" user from evarga's image is part of the "docker"
# group. Needed to access the docker daemon's unix socket.
RUN usermod -a -G docker jenkins

# Install Notary
ADD notary/notarybin /home/jenkins/notary
RUN chmod +x /home/jenkins/notary
RUN chown -R jenkins:jenkins /home/jenkins/notary 

# place the jenkins slave startup script into the container
ADD jenkins-slave-startup.sh /

CMD ["/jenkins-slave-startup.sh"]
