#!/bin/bash

set -ex

# Change the Permissions on the Docker Sock
chown jenkins:jenkins /var/run/docker.sock &

# start the ssh daemon
/usr/sbin/sshd -D
