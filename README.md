# k8s-kustomize-skaffold-k3d-example

An example local k8s development environment using kustomize, skaffold and k3d.

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