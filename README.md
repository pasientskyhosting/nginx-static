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
sudo docker run -d richarvey/nginx-static
```

You can then browse to ```http://<DOCKER_HOST>:8080``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address.

### Available Configuration Parameters
The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

 - **GIT_REPO** : URL to the repository containing your source code
 - **GIT_BRANCH** : Select a specific branch (optional)
 - **GIT_EMAIL** : Set your email for code pushing (required for git to work)
 - **GIT_NAME** : Set your name for code pushing (required for git to work)
 - **SSH_KEY** : Private SSH deploy key for your repository base64 encoded (requires write permissions for pushing)
 - **GIT_PERSONAL_TOKEN** : Personal access token for your git account (required for HTTPS git access)
 - **GIT_USERNAME** : Git username for use with personal tokens. (required for HTTPS git access)
 - **WEBROOT** : Change the default webroot directory from `/var/www/html` to your own setting
 - **HIDE_NGINX_HEADERS** : Disable by setting to 0, default behavior is to hide nginx version in headers
 - **DOMAIN** : Set domain name for Lets Encrypt scripts


### Dynamically Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time.

There are two methods of pulling code from git, you can either use a Personal Token (recommended method) or an SSH key.

**Note:** We would recommed using a git personal token over an SSH key as it simplifies the set up process. To create a personal access token on Github follow this [guide](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

#### Personal Access token

You can pass the container your personal access token from your git account using the __GIT_PERSONAL_TOKEN__ flag. This token must be setup with the correct permissions in git in order to push and pull code.

Since the access token acts as a password with limited access, the git push/pull uses HTTPS to authenticate. You will need to specify your __GIT_USERNAME__ and __GIT_PERSONAL_TOKEN__ variables to push and pull. You'll need to also have the __GIT_EMAIL__, __GIT_NAME__ and __GIT_REPO__ common variables defined.

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' richarvey/nginx-static:latest
```

To pull a repository and specify a branch add the __GIT_BRANCH__ environment variable:
```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=stage' richarvey/nginx-static:latest
```
#### SSH keys

##### Preparing your SSH key
The container has the option for you to pass it the __SSH_KEY__ variable with a **base64** encoded private key. First generate your key and then make sure to add it to github and give it write permissions if you want to be able to push code back out the container. Then run:
```
base64 -w 0 /path_to_your_key
```
**Note:** Copy the output be careful not to copy your prompt

##### Running with SSH Keys

To run the container and pull code simply specify the GIT_REPO URL including *git@* and then make sure you have also supplied your base64 version of your ssh deploy key:
```
sudo docker run -d -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' richarvey/nginx-static:latest
```

To pull a repository and specify a branch add the GIT_BRANCH environment variable:
```
sudo docker run -d -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' -e 'GIT_BRANCH=stage' richarvey/nginx-static:latest
```

### Enabling SSL or Special Nginx Configs
You can either map a local folder containing your configs  to /etc/nginx or we recommend editing the files within __conf__ directory that are in the git repo, and then rebuilding the base image.

### Lets Encrypt support (Experimental)
#### Setup
You can use Lets Encrypt to secure your container. Make sure you start the container ```DOMAIN, GIT_EMAIL``` and ```WEBROOT``` variables to enable this to work. Then run:
```
sudo docker exec -t <CONTAINER_NAME> /usr/bin/letsencrypt-setup
```
Ensure your container is accessible on the ```DOMAIN``` you supply in order for this to work
#### Renewal
Lets Encrypt certs expire every 90 days, to renew simply run:
```
sudo docker exec -t <CONTAINER_NAME> /usr/bin/letsencrypt-renew
```

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
sudo docker run -d -e 'YOUR_VAR=VALUE' richarvey/nginx-static
```

## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
### WebRoot
You can set your webroot in the container to anything you want using the -e "WEBROOT=/var/www/html/public" variable. By default code is checked out into /var/www/html/ so if your git repository does not have code int he root you'llneed to use this variable.
