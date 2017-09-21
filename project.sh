#!/bin/bash
# - - - - - - - - -  - - - - - - - - - -
# @company      MDN Solutions
# @author       Renato Medina <renato@mdnsolutions.com>
# - - - - - - - - -  - - - - - - - - - -

# - - - - - - - - -  - - - - - - - - - -
# Global Variables
# - - - - - - - - -  - - - - - - - - - -
source ./env.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# - - - - - - - - -  - - - - - - - - - -
# Help
# - - - - - - - - -  - - - - - - - - - -
for var in "$@"
do
    if [ "$var" == "--help" ]; then
        echo -e "Usage:"
        echo -e "\tproject [--install]"
        exit
    fi
done


# - - - - - - - - -  - - - - - - - - - -
# Check config files
# - - - - - - - - -  - - - - - - - - - -
if [ ! -f env.sh ]; then
    echo -e "${RED}Please create your env.sh file. Check env.sh_sample.${NC}"
    exit
fi

if [ ! -f install_commands.sh ]; then
    echo -e "${RED}Please create your install_commands.sh file. Check install_commands.sh_sample.${NC}"
    exit
fi

if [ ! -f docker-compose.yml ]; then
    echo -e "${RED}Creating docker-composer.yml...${NC}"
    cp docker-compose.yml_sample docker-compose.yml
fi

# - - - - - - - - -  - - - - - - - - - -
# Containers
# - - - - - - - - -  - - - - - - - - - -
echo -e "${GREEN}Stopping all the running containers...${NC}"
docker stop $(docker ps -q)
sleep 2

mkdir -p $ROOT_DIR'/www'

for var in "$@"
do
    if [ "$var" == "--install" ]; then
        echo -e "${GREEN}Setting up Magento version configurations${NC}"
        if [ "$MAGENTO_VERSION" == "m1" ]; then
            cat $ROOT_DIR/docker/etc/nginx/magento1_sample.conf > $ROOT_DIR/docker/etc/nginx/default.conf
            cat $ROOT_DIR/docker/php/Dockerfile_php56 > $ROOT_DIR/docker/php/Dockerfile
        elif [ "$MAGENTO_VERSION" == "m2" ]; then
            cat $ROOT_DIR/docker/etc/nginx/magento2_sample.conf > $ROOT_DIR/docker/etc/nginx/default.conf
            cat $ROOT_DIR/docker/php/Dockerfile_php70 > $ROOT_DIR/docker/php/Dockerfile
        fi
        sed -i -e "s/local.sample.com/$SERVER_NAME/g" $ROOT_DIR/docker/etc/nginx/default.conf

        # Settings
        sed -i -e "s/sample-mysql/$CONTAINER_DB/g" $ROOT_DIR/docker-compose.yml
        sed -i -e "s/sample-php/$CONTAINER_PHP/g" $ROOT_DIR/docker-compose.yml
        sed -i -e "s/sample-nginx/$CONTAINER_NGNIX/g" $ROOT_DIR/docker-compose.yml
        sed -i -e "s/sample-redis/$CONTAINER_REDIS/g" $ROOT_DIR/docker-compose.yml

        echo -e "${GREEN}Starting containers...${NC}"
        docker-compose up -d
        sleep 2

        echo -e "${GREEN}Running custom install commands...${NC}"
        source install_commands.sh
        
        echo -e "${BLUE}- Note: Add the line below to your '/etc/hosts' file:${NC}"
        echo -e "${BLUE}127.0.0.1 mysql redis${NC}"
    fi
done

echo -e "${GREEN}Starting containers...${NC}"
docker-compose up -d
sleep 2

# Shows status
echo -e "${GREEN}Checking containers...${NC}"
docker ps

# - - - - - - - - -  - - - - - - - - - -
# Environment
# - - - - - - - - -  - - - - - - - - - -
# Non-GNU/Linux platforms need a VM
if [ "$(expr substr $(uname -s) 1 5)" != "Linux" ]; then
    # Starts vm
    if [ "$(docker-machine status $VM_NAME)" == 'Running' ]; then
        echo -e "${GREEN}Stopping Docker Machine...${NC}"
        docker-machine stop $VM_NAME
        sleep 1
    fi

    echo -e "${GREEN}Starting Docker Machine...${NC}"
    docker-machine start $VM_NAME
    eval $(docker-machine env $VM_NAME)

    # Speed up the docker machine with NFS
    docker-machine-nfs $VM_NAME

    # Fixes the IP issue "This machine has been allocated an IP address, but Docker Machine could not reach it successfully."
    #sudo ifconfig vboxnet0 down && sudo ifconfig vboxnet0 up && docker-machine restart $VM_NAME

    # If needed, regenerate TLS connection certs, requires confirmation
    #docker-machine regenerate-certs $VM_NAME
    sleep 1
fi
