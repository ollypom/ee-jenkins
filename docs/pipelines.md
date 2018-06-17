# Jenkins Guide for Docker EE - Pipelines

Depending on what you are building, i'm pretty sure you will have your own pipelines defined. That being said here is some instructions for a Demo pipeline. The first will build you a docker image, on top of the Docker EE cluster. The second will push your new docker image to a Docker Trusted Registry (DTR).

## Building your Slave Image

Slave images will end up being unique to you, mine will need to include my UCP CA certificates, a Docker EE client, and a Notary client. The example Dockerfile lives [here](jenkins-slaves/Dockerfile).

On a local machine.

```
$ DTR=dtr.olly.dtcntr.net
$ VER=0.1
$ cd jenkins-slave
$ docker build -t ${DTR}/admin/jenkins-slave:${VER}
$ docker push ${DTR}/admin/jenkins-slave:${VER}
```

## Creating a Build Pipeline

**Install Webhook Plugin**

For my build pipeline, I take advantage of a Webhook Trigger from Github. Therefore this will need to be installed. `Manage Jenkins > Manage Plugins > Available`: Generic Webhook Trigger.

![Webook Trigger](/docs/images/webhooktrigger.png?raw=true "Webook Trigger")

**Define a User for Webhook Plugins**

From the Jenkins homepage go to `Manage Jenkins > Manage Users > Create User`. Create a new user:

![New User](/docs/images/newuser.png)

**Docker Trusted Registry (Prereqs)**

For this demonstration we are building a Docker Image and pushing the image to a Docker Trusted Registry (DTR).

* Firstly a User will need to create a repository in DTR. Mine is called `dave/demo-app`.

* Secondly we will need to add credentials into Jenkins access DTR, allowing a push.

From Jenkins `Credentials > System > Global Credentials > Add Credentials`. This credentials need to be created with type username and password, and this user needs to have write permissions to the `dave/demo-app` repository. *Note I have added the credentials id to the jenkinsfile, allowing jenkins to reference it*

**Define Pipeline**

Login to the Jenkins UI > New Item > Pipeline. Mine is named `ee-build`.

Feel free to add a Description. I also add a `Discard Old Builds >  Max # of Builds to Keep` value in to stop sprawl. 

For `Build Triggers` select the `Generic Webhook Trigger` option, however leave all of its fields on default. Secondly select the `Trigger builds remotely` field at the bottom of the `Build Triggers` section. Add a custom value, I have personally used `build`. This means that you have now have a bespoke URL to hit, to start this pipeline. `${jenkins-url}/generic-webhook-trigger/invoke?token=build`

My Jenkinsfiles actually live in this repostory, so under the `pipeline` section here, configure your SCM. Please see my jenkinsfile's for reference:

* [Swarm](jenkinsfiles/Jenkinsfile-build-swarm)
* [Kubernetes](jenkinsfiles/Jenkinsfile-build-kube)

![Pipeline Defintion](/docs/images/pipelinedefintion.png)

And Click Save :)

This pipeline can be quickly tested by curling the Webhook trigger:

```
$ JUSR=jenkinsuser
$ JPWD=jenkinsuserpassword
$ JURL=jenkinsurl
$ curl -vs http://${JUSR}:{JPWD}@${JURL}/generic-webhook-trigger/invoke?token=build
```

**Configure Github Push's to Trigger Builds**

This repository, is paired with a [demo app](https://github.com/ollypom/ee-demo-app). We will configure a webhook, so any changes to this demo app will trigger a new docker build.

Browser to the repository on Github, click `settings > webooks > add webhook`.

For the payload url add in your URL with this variables defined: `http://${JUSR}:{JPWD}@${JURL}/generic-webhook-trigger/invoke?token=build`

Feel free to test it out, with a push to that repo.

## Build a Promotion Pipeline

To demonstate a "Secure Supply Chain with Docker EE" we are going to create a second pipeline, to do some testing and promotion of a Docker Image, once it arrive in the QA repository within our registry.

**Define Pipeline**

Login to the Jenkins UI > New Item > Pipeline. Mine is named `ee-testing`.

Feel free to add a Description. I also add a `Discard Old Builds >  Max # of Builds to Keep` value in to stop sprawl. 

For `Build Triggers` select the `Generic Webhook Trigger` option, however leave all of its fields on default. Secondly select the `Trigger builds remotely` field at the bottom of the `Build Triggers` section. Add a custom value, I have personally used `testing`. This means that you have now have a bespoke URL to hit, to start this pipeline. `${jenkins-url}/generic-webhook-trigger/invoke?token=testing`

My Jenkinsfiles actually live in this repostory, so under the `pipeline` section here, configure your SCM. Please see my jenkinsfile's for reference:

* [Swarm](jenkinsfiles/Jenkinsfile-qa-swarm)
* [Kubernetes](jenkinsfiles/Jenkinsfile-qa-kube)

![Pipeline Defintion QA](/docs/images/pipelinedefintionqa.png)

And Click Save :)

**Docker Trusted Registry (Prereqs)**

For this demonstration we are going to be showing an Image that is currently living in a developers namespace (dave/demo-app), promoted through to a testing namespace (testing/demo-app) and then ending up in a production namespace (prod/demo-app). 

Pre-reqs for DTR:
* All 3 Repositories Created
* A Promotion Policy. If image in dave/demo-app is clean, promote to testing/demo-app.
* A Webhook. When an image is promoted from dave/demo-app send a trigger to `${jenkins-url}/generic-webhook-trigger/invoke?token=testing`

**Envirmental Variables (Kube)**

To add Image Signing to this build step, we need to add a few variables to the Jenkins Slave. This include a User's `key.pem` file from their UCP client bundle. A Secret file containing the notary delegate and root passphrases, an example of this lives [Kubernetes](jenkins-slave/kubernetes/secret.yaml).

Before this pipeline can run, you will need to run:

```
$ kubectl create -f jenkins-slave/kubernetes/secret.yaml
$ kubectl create secret generic ucp-testing-key --from-file=jenkins-slave/kubernetes/key.pem
```

**Envirmental Variables (Swarm)**

Swarm Pre-Reqs hasn't been done yet, sorry :( 

**Envirmental Variables (Notary)**

Signing hasn't been finished yet. Sorry :(