# k3s-kustomize-skaffold-k3d-example

An example local [k3s](https://github.com/rancher/k3s) development environment using [kustomize](https://github.com/kubernetes-sigs/kustomize), [skaffold](https://github.com/GoogleContainerTools/skaffold) and [k3d](https://github.com/rancher/k3d). 

**NB.** The setup is tested on `macOS Mojave`.

![](./flow.gif)

### Features
- Bootstraps k3s cluster using k3d
- Creates a local insecure registry in order that Skaffold can push images using local Docker as builder and k3s can pull the images
- Kustomize uses [Directory Structure Based Layout](https://kubectl.docs.kubernetes.io/pages/app_composition_and_deployment/structure_directories.html)
- Skaffold uses kustomize for building and deploying k8s manifests using [local](#kustomize-directory-structure-based-layout) overlay
- An example `node.js` app will be bootstrapped with [File sync](https://skaffold.dev/docs/how-tos/filesync/) and [Port forward](https://skaffold.dev/docs/how-tos/portforward/) enabled

### Prerequisites
- Docker Desktop [installed](https://docs.docker.com/install/)
- kubectl [installed](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- kustomize [installed](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/INSTALL.md)
- Skaffold [installed](https://skaffold.dev/docs/getting-started/#installing-skaffold)
- k3d [installed](https://github.com/rancher/k3d)

### Usage
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
$ skaffold dev --port-forward
```
An example node.js app is available at:
```sh
localhost:3000
```
Make some changes to `src/index.js` and they will be synchronized to the pod(s) running the app.


## Kustomize Directory Structure Based Layout
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
    ├── production
    │   ├── deployment-patch.yaml
    │   ├── hpa-patch.yaml
    │   ├── kustomization.yaml
    └── staging
        ├── deployment-patch.yaml
        ├── hpa-patch.yaml
        ├── kustomization.yaml
```