# KIND

## CREATE

<details><summary>GENERATE CLUSTER CONFIG</summary>

```bash
IP=$(hostname -I | awk '{print $1}')
KUBE_API_PORT=31943
CLUSTER_NAME=kind-demo
CLUSTER_CONFIG_PATH=/tmp/${CLUSTER_NAME}-cluster.yaml

kcl run --quiet oci://ghcr.io/stuttgart-things/k8s-kind-cluster \
-D portRangeStart=32100 \
-D portRangeCount=2 \
-D clusterName=${CLUSTER_NAME} \
-D apiServerAddress=${IP} \
-D 'registryMirrors=["https://docker.harbor.idp.kubermatic.sva.dev"]' \
-D apiServerPort=${KUBE_API_PORT} > ${CLUSTER_CONFIG_PATH}
```

</details>

<details><summary>CREATE CLUSTER</summary>

```bash
KUBE_API_PORT=31943
CLUSTER_NAME=kind-demo
CLUSTER_CONFIG_PATH=/tmp/${CLUSTER_NAME}-cluster.yaml

KUBECONFIG_PATH=~/.kube/kind-${CLUSTER_NAME}

mkdir -p ~/.kube || true

kind create cluster \
--config ${CLUSTER_CONFIG_PATH} \
--kubeconfig ${KUBECONFIG_PATH}

# REPLACE IP
yq -i '.clusters[0].cluster.server = "https://'"$(hostname -I | awk '{print $1}')"':'"${KUBE_API_PORT}"'"' ${KUBECONFIG_PATH}


export KUBECONFIG=${KUBECONFIG_PATH}
kubectl get nodes
```

</details>

<details><summary>DEPLOY CLUSTER-INFRA</summary>

```bash
kcl run oci://ghcr.io/stuttgart-things/helmfile-kind \
-D apps=cilium,cert_manager \
-D cilium_configure_lb=True \
-D ciliumClusterName=bla \
-o /tmp/kind-infra.yaml

## DEPLOY CLUSTER-INFRA
export KUBECONFIG=${KUBECONFIG_PATH}
export HELMFILE_CACHE_HOME=/tmp/helm-cache

helmfile init --force

kubectl apply -k https://github.com/stuttgart-things/helm/infra/crds/cilium
kubectl apply -k https://github.com/stuttgart-things/helm/infra/crds/cert-manager

helmfile apply -f /tmp/kind-infra.yaml

kubectl get nodes
```

</details>

<details><summary>CREATE KUBECONFIG SECRET ON VAULT</summary>

```bash
curl \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  --request POST \
  --data @<(cat <<EOF
{
  "data": {
    "kubeconfig": "$(base64 -w0 < ${KUBECONFIG_PATH})"
  }
}
EOF
) \
  $VAULT_ADDR/v1/secrets/data/kubeconfigs/kv/kind-demo
```

</details>

<details><summary>READ IT BACK</summary>

```bash
curl -s \
  --header "X-Vault-Token: $VAULT_TOKEN" \
  $VAULT_ADDR/v1/kubeconfigs/data/kv/demo-infra \
  | jq -r .data.data.kubeconfig | base64 -d > ./demo-infra.kubeconfig
```

</details>


<details><summary>DEPLOY VCLUSTER</summary>

```bash
# CREATE VALUES
---
controlPlane:
  statefulSet:
    persistence:
      volumeClaim:
        storageClass: standard
  distro:
    k8s:
      enabled: true

  proxy:
    bindAddress: "0.0.0.0"
    port: 8443
    extraSANs:
      - "maverick.tiab.labda.sva.de"
      - "10.100.136.150"
      - "localhost"  # Add for local access

  service:
    enabled: true
    spec:
      type: NodePort
      ports:
        - name: https
          port: 443
          targetPort: 8443
          nodePort: 32443
          protocol: TCP

exportKubeConfig:
  server: "https://10.100.136.150:32443"
  # Or use hostname:
  # server: "https://maverick.tiab.labda.sva.de:32443"
```

```bash
# INSTALL
helm repo add loft https://charts.loft.sh && \
helm repo udpate

helm upgrade --install xplane  \
loft/vcluster --version 0.29.0  \
--create-namespace -n vcluster  \
--values vcluster.yaml
```

</details>

<details><summary>DESTROY CLUSTER</summary>

```bash
# DELETE
kind delete clusters platform-cluster
```

</details>
