# jenkinsci/jenkins is official repo
# jenkins:lts is debian based 800mb, jenkins:lts-alpine is 200mb.
FROM jenkinsci/jenkins:2.lts-alpine
MAINTAINER ollypom

# Add your UCP/DDR CA into an existing ca-cerificates file and copy this into the container.
#USER root
#COPY certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
#RUN chmod +r /etc/ssl/certs/ca-certificates.crt

# Copy Accross UCP Certs
USER root
COPY ucp-bundle-jenkins.zip /home/jenkins/
RUN (unzip /home/jenkins/ucp-bundle-jenkins.zip -d /home/jenkins/ && \
    cp /home/jenkins/ca.pem /usr/local/share/ca-certificates/ca.pem && \
    update-ca-certificates)

# Copy your UCP CA cert itself into the container and so Jenkins itself can talk to your Docker EE Components
RUN \
    cp /home/jenkins/ca.pem $JAVA_HOME/jre/lib/security/ucp.crt && \
    cd $JAVA_HOME/jre/lib/security && \
    keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ucpcert -file ucp.crt && \
    rm -rf /home/jenkins

# Switch back to Jenkins User before running the container
USER jenkins
