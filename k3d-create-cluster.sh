#!/bin/bash
set -eo pipefail

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[0;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_WHITE="\033[1;37m"
NO_COLOR="\033[0m"

main () {
    echo -e ${COLOR_WHITE}
    read -p "Proceed creating a local insecure registry and install k3s cluster? [y/n] " answer
    echo -e ${NO_COLOR}
}

if [ $answer = y ]; then
  create_local_registry
else
  echo exiting..
fi
}

create_local_registry () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating local insecure registry ${COLOR_GREEN}" ${NO_COLOR}

    docker volume create local_registry
    docker container run -d --name registry.local -v local_registry:/var/lib/registry --restart always -p 5000:5000 registry:2

    create_configuration
}

create_configuration () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating configuration for the cluster ${COLOR_GREEN}" ${NO_COLOR}

    HOME_DIR=~/${USER}/.k3d

    mkdir -p ${HOME_DIR}
    cp ./k3d/config.toml.tmpl ${HOME_DIR}

    create_cluster
}

create_cluster () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Creating the cluster ${COLOR_GREEN}" ${NO_COLOR}

    CLUSTER_NAME=k3s-local
    k3d create \
    --name ${CLUSTER_NAME} \
    --wait 0 \
    --auto-restart \
    --volume ${HOME_DIR}/config.toml.tmpl:/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl

    connect_registry
}

connect_registry () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Connecting the registry to the cluster network ${COLOR_GREEN}" ${NO_COLOR}

    docker network connect k3d-${CLUSTER_NAME} registry.local

    add_registry_to_hosts
}

add_registry_to_hosts () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e ${COLOR_WHITE}"Adding 127.0.0.1 registry.local to /etc/hosts ${COLOR_GREEN}" ${NO_COLOR}

    echo "127.0.0.1 registry.local" >> /etc/hosts

    post_information
}

post_information () {
    echo
    echo -e "${COLOR_CYAN}#######################################################################################################${NO_COLOR}"
    echo -e "${COLOR_WHITE}In order to connect k3s cluster using kubectl, please switch to k3s context using command: export KUBECONFIG="$(k3d get-kubeconfig --name='${CLUSTER_NAME}')" ${NO_COLOR}"
}

main "$@"; exit

