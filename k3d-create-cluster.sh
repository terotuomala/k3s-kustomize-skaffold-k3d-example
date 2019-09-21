#!/bin/bash
set -eo pipefail

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_WHITE="\033[1;37m"
NO_COLOR="\033[0m"

echo -e ${COLOR_GREEN}
echo -e "  _____ _____ _____  "
echo -e " || k ||| 3 ||| s || "
echo -e " ||___|||___|||___|| ${COLOR_YELLOW} Bootstrap k3s cluster including a local insecure registry with k3d. Version 1.0. ${COLOR_GREEN}"
echo -e " |/___\|/___\|/___\| "
echo -e ${NO_COLOR}

main () {
    echo
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating local insecure registry ${COLOR_GREEN}" ${NO_COLOR}
    echo

    REGISTRY_NAME=registry.local
    VOLUME_NAME=local_registry

    if [ ! "$(docker ps -aq -f name=${REGISTRY_NAME} && docker volume ls -q -f name=${VOLUME_NAME})" ]; then
        create_configuration
    else
        echo -e ${COLOR_WHITE}
        read -p "Insecure registry already exists, re-create the registy? [y/n] " RE_CREATE_REGISTRY
        echo -e ${NO_COLOR}

        if [ ! ${RE_CREATE_REGISTRY} = y ]; then
            create_configuration
        else
            docker rm -f ${REGISTRY_NAME}
            docker volume rm ${VOLUME_NAME}

            docker volume create ${VOLUME_NAME}
            docker container run -d --name ${REGISTRY_NAME} -v ${VOLUME_NAME}:/var/lib/registry --restart unless-stopped -p 5000:5000 registry:2

            create_configuration
        fi
    fi
}

create_configuration () {
    echo
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Copying configuration file for the cluster ${COLOR_GREEN}" ${NO_COLOR}
    echo

    HOME_DIR=~/${USER}/.k3d
    CONFIG_FILE=config.toml.tmpl

    mkdir -p ${HOME_DIR}
    cp ./k3d/${CONFIG_FILE} ${HOME_DIR}

    if [ ! -f ${HOME_DIR}/${CONFIG_FILE} ]; then
        echo "Could not copy configuration file to: ${HOME_DIR}"
    else
        echo "Configuration file successfully copied to: ${HOME_DIR}/${CONFIG_FILE}"
        check_cluster
    fi
}

check_cluster () {
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Checking if the cluster already exists ${COLOR_GREEN}" ${NO_COLOR}
    
    CLUSTER_NAME=k3s-local

    if [ ! "$(k3d list | grep -o ${CLUSTER_NAME})" ]; then
        create_cluster
    else
        echo -e ${COLOR_WHITE}
        read -p "Cluster with name ${CLUSTER_NAME} already exists, re-create it? [y/n] " RE_CREATE_CLUSTER
        echo -e ${NO_COLOR}

        if [ ! ${RE_CREATE_CLUSTER} = y ]; then
            connect_registry
        else
            k3d delete -n ${CLUSTER_NAME}
            create_cluster
        fi
    fi
}

create_cluster () {
    echo -e ${COLOR_WHITE}
    read -p "How many workers would you like to have? " WORKERS
    echo -e ${NO_COLOR}

    if [ ! ${WORKERS} -eq 0 ]; then
        echo
        echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
        echo -e ${COLOR_WHITE}"Creating the cluster ${COLOR_GREEN}" ${NO_COLOR}
        echo

        k3d create \
        --name ${CLUSTER_NAME} \
        --workers ${WORKERS} \
        --wait 0 \
        --auto-restart \
        --volume ${HOME_DIR}/config.toml.tmpl:/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
            
        connect_registry
    else
        echo "Cluster must have at least one worker.."
    fi
}

connect_registry () {
    echo
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Connecting the registry to the cluster network ${COLOR_GREEN}" ${NO_COLOR}
    echo

    if [ ! "$(docker network ls -q -f name=k3d-${CLUSTER_NAME})" ]; then
        docker network connect k3d-${CLUSTER_NAME} ${REGISTRY_NAME}
        add_registry_to_hosts
    else
        echo "Registry already connected to cluster network"
        add_registry_to_hosts
    fi
}

add_registry_to_hosts () {
    echo
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Adding ${REGISTRY_NAME} to /etc/hosts ${COLOR_GREEN}" ${NO_COLOR}
    echo

    HOST_NAME="127.0.0.1 registry.local"
    HOST_FILE="/etc/hosts"

    if [ ! "$(grep -o "${HOST_NAME}" ${HOST_FILE})" ]; then
        sudo -- sh -c -e "echo '127.0.0.1 registry.local' >> /etc/hosts"
        post_information
    else
        echo "Entry '${HOST_NAME}' already exists"
        post_information
    fi
}

post_information () {
    echo
    echo -e "${COLOR_CYAN}###################################################################################################################${NO_COLOR}"
    echo -e "${COLOR_WHITE}In order to connect k3s cluster using kubectl, please point your KUBECONFIG to k3s context using command:${NO_COLOR}"
    echo
    echo -e "${COLOR_WHITE}export KUBECONFIG=$(k3d get-kubeconfig --name=${CLUSTER_NAME})${NO_COLOR}"
    echo
}

main "$@"; exit

