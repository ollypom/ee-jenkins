# Jenkins Guide for Docker EE - Swarm

> Note if you are self hosting Jenkins outside of a Docker EE Pod see the last 
> section "Configure a Self Hosted Jenkins' Cloud Provider".

> Note this works for both Linux and Windows Build Agents. However the Master
> in this example is always deployed on Linux.

**(Optional) Build your images and push them to Docker Trusted Registry**

The upstream Jenkins images for their [master](https://hub.docker.com/r/jenkins/jenkins/) 
and [slave](https://hub.docker.com/r/jenkins/jnlp-slave/) work really well, 
however you may need to customise them to work in your environment. For me that 
involved adding my Custom CA to the Jenkins Master, and for my Jenkins Slaves
adding the Docker Client and Git. 

In the Kubernetes world we can use 2 containers in the same pod for our slaves, 
1 container being the jnlp-Slave, the second having our tools embedded. However 
for Docker Swarm we need that 1 task to do it all :) 

```
$ export DTR=https://
$ export VERSION=2.88

# Master
$ cd ../jenkins-master/swarm/
$ docker build -t ${DTR}/admin/jenkins:${VERSION} .
$ docker push ${DTR}/admin/jenkins:${VERSION} 

$ cd ../jenkins-slave/swarm/linux
$ docker build -t ${DTR}/admin/jenkins-slave-linux:${VERSION} .
$ docker push ${DTR}/admin/jenkins-slave-linux:${VERSION}

$ cd ../jenkins-slave/swarm/windows
$ docker build -t ${DTR}/admin/jenkins-slave-windows:${VERSION} .
$ docker push ${DTR}/admin/jenkins-slave-windows:${VERSION}
```

## Deploy Your Master

This can step can be done within the UCP UI or by sourcing the Client bundle and
 using the Docker Client. The example compose file in the repository does 
contain some labels for the Docker EE L7 Routing Mesh. This will need to be 
changed for your environemnt :)

```
$ unzip ucp-bundle-admin.zip
$ source env.sh

$ cd ../jenkins-master/swarm/
$ docker stack deploy -c docker-compose.yml ci
``` 


**Configure Jenkins**

Browse to the URL of Jenkins master. It will ask you for the initial admin
password. This can be found in the Container Logs, or written to a secret
file hidden on the Jenkins Master. 

To read that hidden file:

```
$ id=$(docker ps -q -f "name=ci_jenkins") 
$ docker exec ${id} cat /var/jenkins_home/secrets/initialAdminPassword
```

Once logged in to the Jenkins Master, for ease of use, deploy Jenkins with 
the default Plugins and configure a new user.


**Install the Required Plguins**

For this small environment we require 2x Jenkins plugins to build a Software
Supply Chain. The first is the `Docker Plugin` and the Second is the `Generic
Webhook Trigger Plugin`.

**Add UCP Credentials to Jenkins**

In Jenkins go to Credentials > System > Global Credentials (unrestricted)

- Add Credentials
- Select Type `Docker Host Certificate Authentication`
- In each file enter the relevant data from a Universal Control Plane client 
bundle. Client Key = `key.pem`. Client Certificate = `cert.pem`. Server CA
Certificate = `ca.pem`. Add a relevant ID and Description. Note this should be
a dedicated user within UCP, it would unadvisable to use an Admins client bundle

![Credentials](/docs/images/swarmjenkinscredentials.png?raw=true "Jenkins Credentials")

**Configure a new Cloud Provider**

Next we need to a new a Cloud Provider into Jenkins, telling Jenkins where to 
dynamically provision its builds agents from.

Head to: Manage Jenkins > Configure System. Scroll down to cloud. Add New Cloud.

Give your cloud a Name, specify the URI of the Universal COntrol Plane. Note 
this address should start with `tcp://` and your port number may be different,
by default it is :443. Also select the credentials defined in the previous step
and click test connection. Hopefully everything should be good :)

![Cloud Config](/docs/images/swarmnewcloud.png?raw=true "New Cloud Config")

Finally we need to configure what a build agent should look like with the 
`Docker Agent Templates` section. You can define multiple versions of this, 
depending on what different build agents are doing. For example I have 1 for 
Windows Agents and 1 for Linux Agents. But you could have different build tools 
installed on each agent instead. 

However there are a few mandotory feilds: 

- Name = This is the name that you use in your Jenkinsfiles
- Docker Image = Which Docker Image you want to use for this agent.
- Volumes = If you want to build your container images in a build agent, you
will need to mount the docker socket / pipe here. For Linux the value here 
would be: `/var/run/docker.sock:/var/run/docker.sock`. For Windows the value
would be `\\.\pipe\docker_engine:\\.\pipe\docker_engine`.
- Environment = If you need to pin your build agents to dedicated nodes, whether
that is for security or just for compatibility. E.g. `constraint:os==windows`
- Connect Method = This should always be `Connect with JNLP` as we haven't got 
something like ssh installed within our container images.

![Agent Template](/docs/images/swarmdockeragenttemplate.png?raw=true "Agent Template")

Everything is now good to go for your Jenkins Config. 
Your now ready to build your Pipeline Jobs :)

As the pipelines are consistent with Kubernetes, they can be found here: 
[Pipelines](docs/pipelines.md)
