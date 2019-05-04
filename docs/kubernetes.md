# Jenkins Guide for Docker EE - Kubernetes

> Note if you are self hosting Jenkins outside of a Docker EE Pod see the last
> section "Configure a Self Hosted Jenkins' Cloud Provider".

## Deploy your Master

Fortunatley for Kubernetes, as a service account is mounted into every pod
containing the relevant certificates to communicate with the API server. We do
not need to Build a custom Docker Image, and can use the one straight from
UpStream! Yay!

**Deploy a Namespace and a SA**

Firstly we will create a kubernetes namespace for Jenkins, and also create a
Service account. 

```
$ cd jenkins-master/kubernetes
$ kubectl apply -f jenkins-ns.yaml
```

Inside of the `jenkins-ns.yaml` file we are configuring a few things:

1) Creating a Kubernetes Namespace to house the master and all dynamic slaves 

2) Creating a Kubernetes Service Account, this will be mounted into the Master
and will talk the Kubernetes API to provision slaves for us. 

3) Create a Kubernetes RBAC role to allow the Service account the relevant
persmissions to provision pods. *The Bad News is that because we are mounting
the Docker Socket into slaves to do Docker Builds, the Service Acccount will
need Cluster Admin rights on our Cluster. Hopefully when rootless builders come
around, we can remove these permissions from a service account*. 

4) Apply default limits to all kubernetes pods created in the Jenkins namespace,
just in case an operator forgets to set memory / CPU limits for their slaves, we
will apply a sane default. 

**Persistent Storage (Optional)**

As part of my Jenkins deployment I plan to use an NFS volume to sit behind my
Jenkins master. This will provide my master an element of persistence if it has
to migrate around nodes in my cluster, or as I upgrade the pod over time.

In the example .yaml I have defined a 5Gi volume for use for Jenkins, and have
created the relevant Physical Volume (PV) and Physical Volume Claim (PVC)
within Kubernetes. You would need to adjust this yaml for your NFS server.

```
$ cd jenkins-master/kubernetes
$ kubectl apply -f jenkins-pv.yaml
```

**Deploy the Master**

Now deploy the Jenkins Master. For my instance, I will deploy this as a
Kubernetes Deployment of 1 Replica, I will apply resource contraints and mount
my NFS Volume. This .yaml made need to be customized for your environment. 

Also within this yaml, I will deploy a kubernetes service, exposing the master
on ports 80 (For the web UI) and port 5000 (for slave communication back to the
master). To access the UI I have not defined a NodePort or a Loadbalancer.
Instead I plan to user a Kubernetes Ingress Controller, this has already been
deployed on the cluster and is an Optional next step. 

```
$ cd jenkins-master/kubernetes
$ kubectl apply -f jenkins.yaml
```

## Configure Your Master

Browse to the Jenkins Master in Chrome, you will need to retrieve the default
log in password from the Jenkins Master logs.

```
$ kubectl -n jenkins logs jenkins-master-7c898bd487-xhcbc
```

Configure a new password, and install Jenkins with the default plugins. 

**Configure a Cloud Provider**

Firstly we need to install the Kubernetes Plugin. 

Manage Jenkins > Manage Plugins > Available. Search for Kubernetes.

![Kube Plugin](/docs/images/kubeplugin.png?raw=true "Kube Plugin")

Now we can go into the System and Configure the plugin. 

Firstly we will configure the Kubernetes SA credentials within Jenkins. This
give us a user to communicate with the Kubernetes API Server.

Credentials > System > Global Credentials > Add Credentials

![Add SA](/docs/images/addsa.png?raw=true "Add SA")

Next we can Add a new cloud into Jenkins.

Manage Jenkins > Configure System. Scroll down to Cloud. 

There isn't many fields we will need to configure here. Firstly name your
cloud, for the URL I will use the Kubernetes API Server's internal IP which by
default is 10.96.0.1. For Credentials I will select "Secret Text", which should
refer to our Service Account Credential we configured previously. If you click
test connection, it should all work :) 

Note I have also configured a jenkins URL field. This is required so that the
slaves, use the internal kubernetes DNS service to route back to our master.
The field "jenkins-master" refers to our kubernetes service name. 

![Kube Cloud](/docs/images/newkubecloud.png?raw=true "Kube Cloud")

At this point the Master is done. And is ready to configure some build
pipelines. 

As the pipelines are consistent with Swarm, they can be found here:
[Pipelines](pipelines.md)

## Configure a Self Hosted Jenkins' Cloud Provider

This assumes you have got a Jenkins master and the relevant plugins installed
somewhere. If not start from the top to deploy this in containers :D 

As Docker EE uses EC Signed tokens, today we can not use a UCP user to
authenticate Jenkins until they update their [Kubernetes
Client](https://github.com/jenkinsci/kubernetes-cd-plugin/issues/56). Instead
we must use a service account. So here are the steps to get this to work:

1) Create a Jenkins service account in whichever namespace will host your
slaves.

```
$ kubectl create ns jenkins
$ kubectl create sa jenkins-service account -n jenkins
```

2) Give the relevant Grants to this service account.

Login to your UCP as an Administrator > User Management > Grants. To mount the
Docker Socket into a Slave container, we require some high privileges. Click
New Grant in the top corner, select the Jenkins Service account, the Role Full
Control and the Resource Set is All Namespaces.

![SA RBAC](/docs/images/sarbac.png?raw=true "SA RBAC")

3) Create a KubeConfig file using this SA's token

Grab the token (base64 encoded, needs to be decoded for Kubeconfig) from UCP:

```bash
$ kubectl get secrets -n jenkins
NAME                                  TYPE                                  DATA      AGE
default-token-rr6mj                   kubernetes.io/service-account-token   3         40d
jenkins-service-account-token-4fhxl   kubernetes.io/service-account-token   3         40d

$ kubectl -n jenkins get secrets -o json jenkins-service-account-token-4fhxl | jq -j '.data.token' | base64 -d
<tokenisdisplayhere>
```

Grab the CA from a UCP client bundle

```bash
$ unzip ucp-bundle-jeff.zip
$ ls -l
total 40
-rw-r--r-- 1 olly olly  1913 Jun  9 20:55 ca.pem
-rw-r--r-- 1 olly olly   741 Jun  9 20:55 cert.pem
-rw-r--r-- 1 olly olly   177 Jun  9 20:55 cert.pub
-rw-r--r-- 1 olly olly  1148 Jun  9 20:55 env.cmd
-rw-r--r-- 1 olly olly  1313 Jun  9 20:55 env.ps1
-rw-r--r-- 1 olly olly  1141 Jun 15 16:03 env.sh
-rw------- 1 olly olly   227 Jun  9 20:55 key.pem
-rw------- 1 olly olly  4349 Jun  9 20:55 kube.yml

# We need to base 64 encode this:

$ cat ca.pem | base64 -w 0
<yourcawillbehere>
```

Create the Kubeconfig file using this template.

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <yourcawillbehere>
    server: https://<yourucpurl>:6443
  name: mycluster
contexts:
- context:
    cluster: mycluster
    user: jenkins-service-account
  name: mycontext
current-context: mycontext
kind: Config
preferences: {}
users:
- name: jenkins-service-account
  user:
    token: <yourtokenwillbehere>
```

Feel free to test your kubeconfig

```
$ kubectl --kubeconfig=<yourfile>.yml get nodes
NAME                STATUS    ROLES     AGE       VERSION
controller0.local   Ready     master    40d       v1.8.11-docker-8d637ae
controller1.local   Ready     master    40d       v1.8.11-docker-8d637ae
controller2.local   Ready     master    40d       v1.8.11-docker-8d637ae
dtr0.local          Ready     <none>    40d       v1.8.11-docker-8d637ae
worker0.local       Ready     <none>    40d       v1.8.11-docker-8d637ae
worker1.local       Ready     <none>    40d       v1.8.11-docker-8d637ae
```

4) Upload the File into Jenkins Credentials 

Login to Jenkins. Go to Credentials > System > Global Credentials > Add
Credentials. Select Kind Secret File, upload your kubeconfig and give it an ID.

![Upload KubeConfig](/docs/images/uploadkubeconfig.png?raw=true "SA RBAC")

5) Configure Kubernetes Plugin

Login to Jenkins. Go to Manage Jenkins > Configure System. Scroll to the bottom
and find Cloud > Add New Cloud > Kubernetes.

Add in your Kubernetes URL and select the kubeconfig we have just uploaded.
Then hit the Test connection and hopefully everything should work out. 

![Add New Cloud](/docs/images/selfhostedcloudconfig.png?raw=true "SA RBAC")

Finally I added my Jenkins URL in here too, so your slaves can find your
master. Then click save :)

6) At this point the Master is done. And is ready to configure some build
pipelines. 

As the pipelines are consistent with Swarm, they can be found here:
[Pipelines](pipelines.md)
