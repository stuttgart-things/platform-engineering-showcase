# KIND

## PLATFORM CLUSTER

KUBECONFIG_PATH=~/.kube/kind-platform

mkdir -p ~/.kube || true

kind create cluster \
--config platform-cluster.yaml \
--kubeconfig ${KUBECONFIG_PATH}


export KUBECONFIG=${KUBECONFIG_PATH}

## DEPLOY CLUSTER-INFRA

```bash
export KUBECONFIG=${KUBECONFIG_PATH}
export HELMFILE_CACHE_HOME=/tmp/helm-cache

helmfile init --force

for cmd in apply sync; do
  for i in {1..8}; do
    helmfile -f cluster-infra.yaml $cmd && break
    [ $i -eq 8 ] && exit 1
    sleep 15
  done
done
```

## DEPLOY CROSSPLANE

```
helmfile apply -f crossplane.yaml
```

## CONFIGURE CROSSPLANE
