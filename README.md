# stack-kubernetes
Bootstrap the Asyncy Platform on Kubernetes

# Prerequisites

* An existing kubernetes cluster running at least version 1.9. See [https://kubernetes.io/docs/setup/](https://kubernetes.io/docs/setup/) for official instructions.
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Skaffold](https://github.com/GoogleCloudPlatform/skaffold)

# Install

* Confirm that `kubectl` is set to the right context
```shell
kubectl config current-context
```

* Check kubernetes cluster health
```shell
kubectl cluster-info
```

* GKE: Grant cluster-admin to your current identity
```shell
# Get identity
gcloud info | grep Account

# Grant cluster-admin to your identity
kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user=myname@example.org
```

* Install Istio - **optional (not recommended for development environments)**
```shell
./run.sh istio-install
```

* Install Asyncy
```shell
./run.sh asyncy-install
```

# Development

Update your deployed application continuously

* Watches Asyncy platform project source code for any changes and automatically runs a build and deploy when changes are detected. Asyncy platform projects are assumed to be checked out back one directory. See `skaffold.yaml` for configuration.
```shell
./run.sh asyncy-dev
```

# Deploy

Run the Asyncy Skaffold pipeline once

```shell
./run.sh deploy
```
