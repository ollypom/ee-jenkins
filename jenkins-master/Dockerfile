# jenkinsci/jenkins is official repo
# jenkins:lts is debian based 800mb, jenkins:lts-alpine is 200mb.
FROM jenkinsci/jenkins:2.82-alpine
MAINTAINER ollypom

# Add your UCP/DDR CA into an existing ca-cerificates file and copy this into the container.
USER root
COPY certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
RUN chmod +r /etc/ssl/certs/ca-certificates.crt

# Copy your UCP CA cert itself into the container and so Jenkins itself can talk to your Docker EE Components
USER root
COPY certs/ucp.crt $JAVA_HOME/jre/lib/security
RUN \
    cd $JAVA_HOME/jre/lib/security \
    && keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ucpcert -file ucp.crt

# Switch back to Jenkins User before running the container
USER jenkins
