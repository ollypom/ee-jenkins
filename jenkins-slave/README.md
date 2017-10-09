# TODO NEED TO UPDATE FOR DOCKER EE

This repository will give you the Container images for 2 build jobs in Jenkins. 1 to Build Images and 1 to deploy services. These jobs will build images from a github repo, and can the update a deployed service on a UCP cluster.

Inspiration was taken from this blog: https://dantehranian.wordpress.com/2014/10/25/building-docker-images-within-docker-containers-via-jenkins/
And this Github Page: https://github.com/tehranian/dind-jenkins-slave

## Building the Images

Here we have 2 Docker Images. The first will be the "Builder" the second is the "Deployer" in a future version I will combine this into 1 image.

### slave-build

The image is based on Ervin Varga Slave image. Within this he just takes an ubuntu:trusty image and installs a few Jenkins PreReqs like Java and a Jenkins user. **Make sure you open up port 5000 on your AWS security group to allow jenkins to contact a slave**

We then copy the CA certificates for my UCP cluster on the image, install the latest version of the engine, install notary and copy accross a user key for notary.

```bash
$ cd slave-build
$ docker build -t https://${DTR}/slave-build:latest .
$ docker login https://{DTR}
$ docker push https://${DTR}/slave-build:latest
```

### slave-deploy

The image is once again based on the evarga/jenkins-slave image. We then install some pre-req packages for ubuntu, copy accross the UCP CA certs. Download the docker binaries, but remove everything but the client. We then also copy accross the Client Bundle.

```bash
$ cd slave-build
$ docker build -t https://${DTR}/slave-deploy:latest .
$ docker login https://{DTR}
$ docker push https://${DTR}/slave-deploy:latest
```
