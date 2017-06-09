# Jenkins Container
This is a repository to create a custom container with my UCP certificates

INSTRUCTIONS TO CONFIGURE JENKINS ARE IN THE WIKI


## Prepare DTR
Login into DTR and create yourself a repo to push the image into. After this login to the client

```
docker login https://52.56.228.3/
```

## Build the image and push to DTR

```
docker build -t 52.56.228.3/admin/jenkins:latest .
docker push 52.56.228.3/admin/jenkins:latest
```
## TODO Create a Compose File to Run

## Jenkins Plug-Ins Required

Docker Plugin
Yet another Docker Plugin - Credentials Work now!
Git Plugin
Github API plugin
GitHub Authentication plugin - Required to use Access Tokens

## Configuration in Github

Add your Jenkins Server SSH key into Github
A personal Access Token will be inserted thanks to the Github Authentication Plugin. More on that later.

On the repo itself:
Settings > Webooks > Add the payload URL: http://52.56.242.202:30000/github-webhook/

## Jenkins Credentials

Create Username / Password for Docker EE DTR
Create Username / Password for Github
Create Docker Host Certificate Authentication	for Docker UCP

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






