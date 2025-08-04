# KIND

## PLATFORM CLUSTER

```bash
# CREATE CLUSTER
KUBECONFIG_PATH=~/.kube/kind-platform

mkdir -p ~/.kube || true

kind create cluster \
--config platform-cluster.yaml \
--kubeconfig ${KUBECONFIG_PATH}

export KUBECONFIG=${KUBECONFIG_PATH}
kubectl get nodes

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

kubectl get nodes
```


```bash
# DELETE
kind delete clusters platform-cluster
```
