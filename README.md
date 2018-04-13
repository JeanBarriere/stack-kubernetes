# stack-kubernetes
Bootstrap the Asyncy Platform on Kubernetes

# Prerequisites

* An existing kubernetes cluster running at least version 1.9. See [https://kubernetes.io/docs/setup/](https://kubernetes.io/docs/setup/) for official instructions.
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [skaffold](https://github.com/GoogleCloudPlatform/skaffold)

# Install

* Confirm that `kubectl` is set to the right context:
```shell
kubectl config current-context
```

* Check kubernetes cluster health:
```shell
kubectl cluster-info
```

* Install Istio - **optional (not recommended for development environments)**
```shell
./run.sh istio-install
```

* Install Asyncy
```shell
./run.sh asyncy-install
```
