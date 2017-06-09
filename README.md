# Jenkins Container
This is a repository to create a custom container with my UCP certificates

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
