#!/usr/bin/env bash

set -e
  
CPUS=4
MEMORY=4096
K8S_VERSION="v1.9.4"

echo "Starting minikube..."
minikube start \
  --cpus "$CPUS" --memory "$MEMORY" \
  --extra-config=controller-manager.ClusterSigningCertFile="/var/lib/localkube/certs/ca.crt" \
  --extra-config=controller-manager.ClusterSigningKeyFile="/var/lib/localkube/certs/ca.key" \
  --extra-config=apiserver.Admission.PluginNames=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota \
  --kubernetes-version="$K8S_VERSION"
