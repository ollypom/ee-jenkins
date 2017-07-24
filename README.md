# Jenkins Container
This is a repository to create a Jenkins container, with embedded UCP certs, and steps on how to configure Jenkins to work with Github and your UCP Cluster. To build Slave Containers to carry out Jenkins jobs see:

- https://github.com/ollypom/ee-jenkins-slave

## Prepare DTR
Login into DTR and create yourself a repo to push the image into. After this login to the client

```
docker login https://${DTR}/
```

## Build the image and push to DTR

```
docker build -t ${DTR}/admin/jenkins:latest .
docker push ${DTR}/admin/jenkins:latest
```
## Running the Jenkins Container

Source your UCP Credentials and then run:

```
docker stack deploy -c docker-compose.yml jenkins
```

## Jenkins Plug-Ins Required

- Docker Plugin
- Yet another Docker Plugin - Credentials Work now!
- Git Plugin
- Github API plugin
- GitHub Authentication plugin - Required to use Access Tokens

## Configuration in Github

Add your Jenkins Server SSH key into Github

- Github.com > Settings > SSH Keys

![Alt text](/images/githubsshkey.png?raw=true "Jenkins SSH Key")

On the application github repository add a webhook to notify jenkins everytime there is a build:

Settings > Webooks > Add the payload URL: http://${DTR}:30000/github-webhook/

![Alt text](/images/githubwebhook.png?raw=true "Github Webhook")

## Jenkins Credentials

In Jenkins go to Credentials > System > Global Credentials (unrestricted)

Create Docker Host Certificate Authentication for Docker UCP

![Alt text](/images/jenkinscreds.png?raw=true "Jenkins Credentials")

Create a personal access token on Github. Within Jenkins go to Global Credentials and a secret text entry. Insert your Personall Access token here.

Head to Manage Jenkins > System Configuration

Scroll down to Github > Github Servers. Specify your secret text credentials from the list and test the conntection to github.

Create a new Cloud using the Yet another Docker Plugin. And test connectoin :)

![Alt text](/images/NewCloudConfig.png?raw=true "New Cloud Config")

### Everything is now good to go for your Jenkins Config. Your now ready to build your Pipeline Jobs :)
