# K3S BASED - FLUX/CROSSPLANE CLUSTER

<details open>
<summary>INSTALL K3S</summary>

```bash
export TASK_X_REMOTE_TASKFILES=1
task --taskfile https://raw.githubusercontent.com/stuttgart-things/tasks/refs/heads/main/kubernetes/k3s.yaml install
task --taskfile https://raw.githubusercontent.com/stuttgart-things/tasks/refs/heads/main/kubernetes/k3s.yaml cilium:install
```

</details>

<details open>
<summary>INSTALL FLUX OPERATOR</summary>

```bash
helmfile init --force
helmfile apply -f git::https://github.com/stuttgart-things/helm.git@cicd/flux-operator.yaml.gotmpl \
--state-values-set version=0.28.0
```

</details>

<details open>
<summary>RENDER FLUX CONFIG</summary>

```bash
dagger call -m github.com/stuttgart-things/dagger/kcl@v0.76.0 run \
--oci-source ghcr.io/stuttgart-things/kcl-flux-instance:0.3.3 \
--parameters " \
name=flux, \
namespace=flux-system, \
gitUrl=https://github.com/stuttgart-things/stuttgart-things.git, \
gitRef=refs/heads/main, \
gitPath=clusters/edge/xplane, \
pullSecret=git-token-auth, \
renderSecrets=true, \
gitUsername=patrick-hermann-sva, \
gitPassword=$GITHUB_TOKEN, \
sopsAgeKey=$SOPS_AGE_KEY, \
version=2.4" \
export -path ./flux-instance.yaml
```

</details>

<details open>
<summary>ADD CLUSTER TO CROSSPLANE (SOPS ENCRYPTED)</summary>

```bash
dagger call -m github.com/stuttgart-things/blueprints/crossplane-configuration add-cluster \
--clusterName=in-cluster \
--deploy-to-cluster=false \
--kubeconfig-cluster file:///home/sthings/.kube/k3s \
--encrypt-with-^Cps=true \
--age-public-key=env:AGE_PUB \
export --path=/tmp/output.yaml \
--progress plain -vv
```

</details>

<details open>
<summary>INSTALL CLAIMS</summary>

```bash
wget https://github.com/stuttgart-things/claims/releases/download/v0.1.0/claims_0.1.0_linux_amd64.tar.gz
tar xvfz claims_0.1.0_linux_amd64.tar.gz
sudo mv claim-machinery-api /usr/bin/
sudo chmod +x /usr/bin/claims
rm -rf claims_0.1.0_linux_amd64.tar.gz
```

</details>


<details open>
<summary>CREATE PROFILE + RUN CLAIM API LOCAL</summary>

```bash
cat <<EOF > profile.yaml
---
templates:
  - https://raw.githubusercontent.com/stuttgart-things/kcl/refs/heads/main/crossplane/claim-xplane-storageplatform/templates/storageplatform-nfs.yaml
  - https://raw.githubusercontent.com/stuttgart-things/kcl/refs/heads/main/crossplane/claim-xplane-storageplatform/templates/storageplatform-openebs.yaml
  - https://raw.githubusercontent.com/stuttgart-things/kcl/refs/heads/main/crossplane/claim-xplane-pipelineintegration/templates/pipelineintegration-simple.yaml
EOF
```

```bash
docker run --rm \
-v $PWD/profile.yaml:/tmp/profile.yaml \
-e TEMPLATE_PROFILE_PATH=/tmp/profile.yaml \
-e TEMPLATES_DIR="/tmp" \
-p 8080:8080 \
ghcr.io/stuttgart-things/claim-machinery-api:v0.3.0
```

</details>
