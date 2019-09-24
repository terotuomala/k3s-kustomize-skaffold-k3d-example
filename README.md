# k3s-kustomize-skaffold-k3d-example

An example local [k3s](https://github.com/rancher/k3s) development environment using [kustomize](https://github.com/kubernetes-sigs/kustomize), [skaffold](https://github.com/GoogleContainerTools/skaffold) and [k3d](https://github.com/rancher/k3d). 

<p align="center"><img src="./k3d-create-cluster-flow.gif?raw=true"/></p>

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [Features](#features)
* [Prerequisites](#prerequisites)
* [Usage](#usage)
* [Kustomize configuration](#kustomize-configuration)


<!-- FEATURES -->
## Features
- Bootstraps k3s cluster in Docker using k3d
- Creates a local insecure registry in order that Skaffold can push images using local Docker as builder and k3s can pull the images
- Skaffold uses kustomize for building and deploying k8s manifests using [local](#kustomize-directory-structure-based-layout) overlay
- An example `node.js` app will be bootstrapped with [File sync](https://skaffold.dev/docs/how-tos/filesync/) and [Port forward](https://skaffold.dev/docs/how-tos/portforward/) enabled

<!-- PREREQUISITES -->
## Prerequisites
**NB.** The setup is tested on `macOS Mojave`.

Docker Desktop [installed](https://docs.docker.com/install/)
```sh
# If you don't want to sign up in order to download Docker
# use the following command to download the installer directly
$ curl -s https://download.docker.com/mac/stable/Docker.dmg
```

kubectl [installed](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
```sh
$ brew install kubernetes-cli
```

kustomize (at least version 2.0.3) [installed](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)
```sh
brew install kustomize
```

Skaffold (at least version v0.38.0) [installed](https://skaffold.dev/docs/getting-started/#installing-skaffold)
```sh
$ brew install skaffold
```

k3d (at least version v1.3.1) [installed](https://github.com/rancher/k3d)
```sh
$ curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash
```

<!-- USAGE -->
## Usage
Create insecure registry, k3s cluster and wire them up using wrapper script:
```sh
$ ./k3d-create-cluster
```
Make sure your KUBECONFIG points to k3s cluster context (if not already):
```sh
$ echo $KUBECONFIG
/Users/<username>/.config/k3d/k3s-local/kubeconfig.yaml
```
Start the local development environment:
```sh
$ skaffold dev -p local --port-forward
```
An example node.js app is available at:
```sh
localhost:3000
```
Make some changes to `src/index.js` and they will be synchronized to the pod(s) running the app.

<!-- KUSTOMIZE CONFIGURATION -->
## Kustomize configuration
Kustomize configuration is based on [Directory Structure Based Layout](https://kubectl.docs.kubernetes.io/pages/app_composition_and_deployment/structure_directories.html) in order to use multiple environments with different configuration. In order to use different clusters remember to specify the corresponding context before applying changes using Skaffold.
```sh
├── base
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── kustomization.yaml
│   └── service.yaml
└── overlays
    ├── local
    │   ├── deployment-patch.yaml
    │   ├── hpa-patch.yaml
    │   ├── kustomization.yaml
    └── test
        ├── deployment-patch.yaml
        ├── hpa-patch.yaml
        ├── kustomization.yaml
```