FROM alpine:3.7
LABEL MAINTAINER=olly@docker.com

ARG UCPURL="https://ucp.olly.dtcntr.net:8443"
ARG NTYURL="https://github.com/theupdateframework/notary/releases/download/v0.4.3/notary-Linux-amd64"

RUN apk add --upgrade --no-cache \
    ca-certificates \
    curl \
    git \
    wget && \
    rm -rf /var/cache/apk/*

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

CMD ["sh", "-c", "tail -f /dev/null"]
