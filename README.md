## Introduction
This is a Dockerfile to build a container image for nginx only, with the ability to pull website code from git.

This is for hosting static pages only and can be used as a template to build other nginx dockerfiles.

### Git
The source files for this project can be found here: [https://github.com/ngineered/nginx-static](https://github.com/ngineered/nginx-static)

If you have any improvements please submit a pull request.
### Docker hub repository


## Versions
| Tag | Nginx | Alpine |
|-----|-------|-----|--------|
| latest | 1.10.1 | 3.4 |

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/ngineered/nginx-static
.git
docker build -t nginx-static:latest .
```

## Pulling from Docker Hub


## Running
To simply run the container:
```
sudo docker run -d ngineered/nginx-static
```

You can then browse to ```http://<DOCKER_HOST>:8080``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address.
### Volumes
If you want to link to your web site directory on the docker host to the container run:
```
sudo docker run -d -v /your_code_directory:/var/www/html ngineered/nginx-static
```

### Dynamically Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

**Note:** You need to have your SSH key that you use with git to enable the deployment. I recommend using a special deploy key per project to minimise the risk.

### Preparing your SSH key
The container expects you pass it the __SSH_KEY__ variable with a **base64** encoded private key. First generate your key and then make sure to add it to github and give it write permissions if you want to be able to push code back out the container. Then run:
```
base64 -w 0 /path_to_your_key
```
**Note:** Copy the output be careful not to copy your prompt

To run the container and pull code simply specify the GIT_REPO URL including *git@* and then make sure you have also supplied your base64 version of your ssh deploy key:
```
sudo docker run -d -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' ngineered/nginx-static
```

To pull a repository and specify a branch add the GIT_BRANCH environment variable:
```
sudo docker run -d -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'GIT_BRANCH=stage' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' ngineered/nginx-static
```

### Enabling SSL or Special Nginx Configs
You can either map a local folder containing your configs  to /etc/nginx or we recommend editing the files within __conf__ directory that are in the git repo, and then rebuilding the base image.

## Special Git Features
You'll need some extra ENV vars to enable this feature. These are ```GIT_EMAIL``` and ```GIT_NAME```. This allows git to be set up correctly and allow the following commands to work.

### Push code to Git
To push code changes made within the container back to git simply run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/push
```

### Pull code from Git (Refresh)
In order to refresh the code in a container and pull newer code form git simply run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```

### Using environment variables

To set the variables simply pass them in as environmental variables on the docker command line.

Example:
```
sudo docker run -d -e 'GIT_REPO=git@git.ngd.io:ngineered/ngineered-website.git' -e 'SSH_KEY=base64_key' -e 'TEMPLATE_NGINX_HTML=1' -e 'GIT_BRANCH=stage' ngineered/nginx-static
```

## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
### WebRoot
You can set your webroot in the container to anything you want using the -e "WEBROOT=/var/www/html/public" variable.

## SECTIONS TO add

- lets encrypt (look at nginx-nodejs)
