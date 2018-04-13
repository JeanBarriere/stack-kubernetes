#!/usr/bin/env bash

check_kubectl() {
  if ! hash kubectl; then
    echo "ERROR: kubectl not found"
    echo "https://kubernetes.io/docs/tasks/tools/install-kubectl/"
    exit 1
  fi
  echo "Current kubectl context: $(kubectl config current-context)"
  read -p "Continue (y/n)?" CONT
  if [ "$CONT" != "y" ]; then
    echo "EXITING - NO CHANGES MADE"
    exit
  fi
}

check_skaffold() {
  if ! hash skaffold; then
    echo "ERROR: skaffold not found"
    echo "https://github.com/GoogleCloudPlatform/skaffold#installation"
    exit 1
  fi
}

kubectl_wrapper() {
  args=$*
  n=0
  until [ $n -ge 10 ]; do
    kubectl $args > /dev/null 2>&1 && break
    n=$((n+1))
    sleep 3
  done
}

istio_install() {
  check_kubectl
  ISTIO_VERSION="0.7.1"
  if [ ! -d "istio-$ISTIO_VERSION" ]; then
    curl -L https://git.io/getLatestIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
  fi
  pushd istio-$ISTIO_VERSION > /dev/null || exit 1

  echo "Installing Istio..."
  # install core istio
  kubectl_wrapper apply -f install/kubernetes/istio-auth.yaml > /dev/null

  # create signed cert for sidecar injection webhook
  ./install/kubernetes/webhook-create-signed-cert.sh --service istio-sidecar-injector --namespace istio-system --secret sidecar-injector-certs > /dev/null 2>&1

  # install sidecar injection configmap
  kubectl_wrapper apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml > /dev/null

  # set caBundle that is used in the webhook
  ./install/kubernetes/webhook-patch-ca-bundle.sh < install/kubernetes/istio-sidecar-injector.yaml > install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

  # install sidecar injector webhook
  kubectl_wrapper apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml > /dev/null

  # prometheus
  kubectl_wrapper apply -f install/kubernetes/addons/prometheus.yaml > /dev/null

  # grafana
  kubectl_wrapper apply -f install/kubernetes/addons/grafana.yaml > /dev/null

  # zipkin
  kubectl_wrapper apply -f install/kubernetes/addons/zipkin.yaml > /dev/null

  # servicegraph
  kubectl_wrapper apply -f install/kubernetes/addons/servicegraph.yaml > /dev/null

  popd > /dev/null
  echo "Waiting for Istio to start..."
  while true; do
    NOT_RUNNING_COUNT=$(kubectl -n istio-system get pod -o=custom-columns=:.status.phase | grep -v "^$" | grep -vc "Running")
    if [ "$NOT_RUNNING_COUNT" -eq 0 ]; then
      break
    else
      sleep 3
    fi
  done

  echo "Istio is ready! Port forwarding commands:"
  echo "Grafana: $ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000"
  echo "Prometheus: $ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090"
  echo "Zipkin: $ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=zipkin -o jsonpath='{.items[0].metadata.name}') 9411:9411"
  echo "Service Graph: $ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088"
}

asyncy_install() {
  check_kubectl
  check_skaffold
  echo "Installing Asyncy..."
  # creating the asyncy namespace
  kubectl_wrapper create namespace asyncy-system

  # enabling istio sidecar injection
  kubectl_wrapper label namespace asyncy-system istio-injection=enabled > /dev/null

  # deploying components
  skaffold run -f skaffold-deploy.yaml

  echo "Asyncy is ready!"
}

usage() {
  echo "Usage: $0 <arg>"
  echo
  echo "Options:"
  echo "istio-install"
  echo "asyncy-install"
}

main() {
  RUN="$1"
  if [ -z "$RUN" ]; then
    usage
    exit 1
  else
    case "$RUN" in
      istio-install)
        istio_install
        ;;
      asyncy-install)
        asyncy_install
        ;;
      *)
        usage
        exit 1
    esac
  fi
}

main "$1"
