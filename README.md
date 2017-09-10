# Overview

For this project it's required having docker running on your machine. 


## Requirements

### Docker

Information about how to install docker [here](https://docs.docker.com/engine/getstarted/step_one/#step-1-get-docker).

### Docker Compose

Install docker composer using the documentation [here](https://docs.docker.com/compose/install/).

### Docker Machine (Required for Non-Linux OS)

Install docker composer using the documentation [here]()https://docs.docker.com/machine/install-machine/).

### Docker Machine NFS (Required for Non-Linux OS)

Speed things up with NFS volumes. Documentation [here](https://github.com/adlogix/docker-machine-nfs).


## Installation

In order to create a Docker environment, please follow the commands below

### 1 - Create your Docker environment folder based on the docker-codebase:

```ssh
git clone git@bitbucket.org:souldigital/docker-codebase.git docker-sample.com.au
```

### 2 - Go into the folder and move the .git folder

```ssh
cd docker-sample.com.au
mv .git .git_docker_codebase
```

### 3 - Create your environment files based on the sample ones.

```ssh
cp env.sh_sample env.sh
cp install_commands.sh_sample install_commands.sh
cp docker-compose.yml_sample docker-compose.yml
```

#### 3.1 - Please update those new files with your project's details
```ssh
vi env.sh
vi install_commands.sh
```

#### 3.2 - Add your docker repository.

```ssh
git init
git remote add origin git@bitbucket.org:souldigital/docker-sample.com.au.git
```

### 4 - Docker-Machine (Required for Non-Linux OS)

Create the virtual machine (Required for Windows/MacOS). You might want to change it for your own needs.

```ssh
docker-machine create --driver virtualbox \
        --virtualbox-cpu-count "2" \
        --virtualbox-memory "4096" \
        --virtualbox-disk-size "64000" \
        dev
```

### 6 - Run the command below to set up the project.

```ssh
./project.sh --install
```

### 7 - Once your project is setup, you can load it any time by using

```ssh
./project.sh
```

# Troubleshooting

## 1. For ERROR: Couldn't connect to Docker daemon. You might need to start Docker for Mac, run the command below first

```ssh
docker-machine start dev && eval $(docker-machine dev)
```

## 2. If issues with "Docker command can't connect to Docker daemon" check [this](http://stackoverflow.com/questions/33562109/docker-command-cant-connect-to-docker-daemon)

```ssh
sudo usermod -aG docker $(whoami)
sudo service docker restart
```
> You might need to restart your machine to restart the user's permissions.

## 3. If you're using Ubuntu, you might have issues to download the latest version of docker-compose.
   Install it with curl:
   
```ssh
sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/local/bin/docker-compose
```

## 4. Where are the hosts file

For Mac Os and Linux, it's usually on /etc/hosts. For Windows, well, whatever.


# Hot tips

## 1 - To update your docker-codebase please use the command below

```ssh
git --git-dir=.git_docker_codebase pull origin master
```

## 2 - Commands to stop and remove all Docker containers:

```ssh
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```


## 3 - In case you need rebuild the containers use 

```ssh
docker-compose build --force-rm --no-cache
docker-compose up -d --force-recreate
```


# References

* https://docs.docker.com/engine/getstarted/step_one/#step-1-get-docker
* http://www.masterzendframework.com/docker-development-environment/
* http://devdocs.magento.com/guides/v2.1/install-gde/install-quick-ref.html
* https://github.com/docker-library/php/issues/75
* http://www.magenerds.com/2016/07/10/setting-up-magento-2-on-docker/
* https://github.com/bytepark/docker-php7-xdebug/blob/master/Dockerfile
* http://andykdocs.de/development/Docker/Dockerize-Magento-2-on-Mac-OS
* https://github.com/adlogix/docker-machine-nfs

