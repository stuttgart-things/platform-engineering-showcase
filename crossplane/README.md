# CROSSPLANE

## DEPLOY CROSSPLANE

```bash
KUBECONFIG_PATH=~/.kube/kind-platform
export HELMFILE_CACHE_HOME=/tmp/helm-cache-xplane
export KUBECONFIG=${KUBECONFIG_PATH}

helmfile apply -f crossplane.yaml
```

## CONFIGURE CROSSPLANE (IN-CLUSTER)

```bash
KUBECONFIG_PATH=~/.kube/kind-platform

# HELM
SA=$(kubectl -n crossplane-system get sa -o name | grep provider-helm | sed -e 's|serviceaccount\/|crossplane-system:|g')
kubectl create clusterrolebinding provider-helm-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"

# KUBERNETES
SA=$(kubectl -n crossplane-system get sa -o name | grep provider-kubernetes | sed -e 's|serviceaccount\/|crossplane-system:|g')
kubectl create clusterrolebinding provider-kubernetes-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"

kubectl apply -f provider-in-cluster
```
