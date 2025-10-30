# KIND

## CREATE

<details><summary>GENERATE CLUSTER CONFIG</summary>

```
IP=$(hostname -I | awk '{print $1}')
KUBE_API_PORT=31943
CLUSTER_NAME=kind-demo

kcl run oci://ghcr.io/stuttgart-things/k8s-kind-cluster \
-D portRangeStart=32100 \
-D portRangeCount=2 \
-D clusterName=${CLUSTER_NAME} \
-D apiServerAddress=${IP} \
-D 'registryMirrors=["https://docker.harbor.idp.kubermatic.sva.dev"]' \
-D apiServerPort=${KUBE_API_PORT} > /tmp/cluster.yaml
```


</details>


<details><summary>CREATE CLUSTER</summary>

```bash
# CREATE CLUSTER
KUBECONFIG_PATH=~/.kube/kind-platform

mkdir -p ~/.kube || true

kind create cluster \
--config cluster.yaml \
--kubeconfig ${KUBECONFIG_PATH}

# REPLACE IP
yq -i '.clusters[0].cluster.server = "https://'"$(hostname -I | awk '{print $1}')"':31643"' ${KUBECONFIG_PATH}


export KUBECONFIG=${KUBECONFIG_PATH}
kubectl get nodes
```

</details>

<details><summary>DEPLOY CLUSTER-INFRA</summary>

```bash
## DEPLOY CLUSTER-INFRA
export KUBECONFIG=${KUBECONFIG_PATH}
export HELMFILE_CACHE_HOME=/tmp/helm-cache

helmfile init --force

kubectl apply -k https://github.com/stuttgart-things/helm/infra/crds/cilium

helmfile apply -f infra.yaml

kubectl get nodes
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
