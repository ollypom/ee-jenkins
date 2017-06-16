# Jenkins Container
This is a repository to create a custom Jenkins container to run on UCP with the correct certs

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

A personal Access Token will be inserted thanks to the Github Authentication Plugin to allow access to private repos. More on that later.

On the application github repository add a webhook to notify jenkins everytime there is a build:

Settings > Webooks > Add the payload URL: http://${DTR}:30000/github-webhook/

![Alt text](/images/githubwebhook.png?raw=true "Github Webhook")

## Jenkins Credentials

In Jenkins go to Credentials > System > Global Credentials (unrestricted)

Create Username / Password for Docker EE DTR
Create Username / Password for Github
Create Docker Host Certificate Authentication for Docker UCP

![Alt text](/images/jenkinscreds.png?raw=true "Jenkins Credentials")

## Jenkins Configuration

Docker Registry Config: 

![Alt text](/images/Registry.png?raw=true "Jenkins - Registry Config")

Creating Github Creds. Go to Github > Advanced > Additional Actions. And Convert Username / Password to token. This will insert a Personal Access token into Github. As mentioned above. 

![Alt text](/images/GithubCreds.png?raw=true "Github Token Creation")

Configuring Github. Use your new token as the creds, and untick manage web hooks. And then test connection.

![Alt text](/images/GithubConnection.png?raw=true "Github Connection")

UNSURE IF Required. Enter the Docker EE Reg Credentials on the Pipeline Model Definition.

UNSURE IF REQIURED. Enter your credentials on the Git Plugin.

Create a new Cloud using the Yet another Docker Plugin. And test connectoin :)

![Alt text](/images/NewCloudConfig.png?raw=true "New Cloud Config")

On the Docker Template. Add your image name. 

On the Docker Create Container settings, we need to give the container persmissions to use Docker in Docker (DIND).
Under Volumes: /var/run/docker.sock:/var/run/docker.sock and tick the run as privileged container tick box.

Hopefully you are then good to go :)






