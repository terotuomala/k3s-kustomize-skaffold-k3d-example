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
    echo -e ${COLOR_WHITE}
    read -p "How many workers would you like to have? " WORKERS
    echo -e ${NO_COLOR}

    if [ ! ${WORKERS} -eq 0 ]; then
        create_local_registry
    else
        echo "Cluster must have at least one worker.."
    fi
}

create_local_registry () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating local insecure registry ${COLOR_GREEN}" ${NO_COLOR}
    echo

    REGISTRY_NAME=registry.local
    VOLUME_NAME=local_registry

    if [ ! "$(docker ps -aq -f name=${REGISTRY_NAME})" ]; then
        if [ ! "$(docker volume ls -q -f name=${VOLUME_NAME})"]; then
            echo -e ${COLOR_WHITE}
            read -p "Insecure registry already running, re-create the registy? [y/n] " CREATE_REGISTRY
            echo -e ${NO_COLOR}

            if [ ! ${CREATE_REGISTRY = y} ]; then
                create_configuration
            else
                docker rm -f ${REGISTRY_NAME}
                docker volume rm ${VOLUME_NAME}

                docker volume create ${VOLUME_NAME}
                docker container run -d --name ${REGISTRY_NAME} -v ${VOLUME_NAME}:/var/lib/registry --restart unless-stopped -p 5000:5000 registry:2
            fi
        fi
            create_configuration
    fi
}

create_configuration () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
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
        create_cluster
    fi
}

create_cluster () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating the cluster ${COLOR_GREEN}" ${NO_COLOR}
    echo

    CLUSTER_NAME=k3s-local
    k3d create \
    --name ${CLUSTER_NAME} \
    --workers ${WORKERS} \
    --wait 0 \
    --auto-restart \
    --volume ${HOME_DIR}/config.toml.tmpl:/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl

    connect_registry
}

connect_registry () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Connecting the registry to the cluster network ${COLOR_GREEN}" ${NO_COLOR}
    echo

    docker network connect k3d-${CLUSTER_NAME} registry.local

    add_registry_to_hosts
}

add_registry_to_hosts () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Adding 127.0.0.1 registry.local to /etc/hosts ${COLOR_GREEN}" ${NO_COLOR}
    echo

    echo "127.0.0.1 registry.local" >> /etc/hosts

    post_information
}

post_information () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e "${COLOR_WHITE}In order to connect k3s cluster using kubectl, please switch to k3s context using command: export KUBECONFIG="$(k3d get-kubeconfig --name='${CLUSTER_NAME}')" ${NO_COLOR}"
}

main "$@"; exit

