# k8s-kustomize-skaffold-k3d-example

An example local k8s development environment using kustomize, skaffold and k3d.

### TL;DR
- Bootstraps k3s cluster using k3d
- Creates a local insecure registry so Skaffold can build images using local Docker
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
Create k3s cluster using k3d:
```sh
$ ./k3d-create-cluster
```
Make sure your kubectl config points to a correct context:
```console
$ kubectl config current-context
k3s-local
```
Start the local development environment:
```sh
$ skaffold dev -p local --port-forward
```
An example node.js app is available at:
```sh
localhost:3000
```
Make some changes to `src/index.js` and they will synced to the pod(s) running the app.


## Kustomize Directory Structure Based Layout
```sh
├── base
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
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