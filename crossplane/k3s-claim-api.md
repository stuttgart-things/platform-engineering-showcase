# K3S BASED - CROSSPLANE CLUSTER

<details open>
<summary>INSTALL CLAIMS</summary>

```bash
wget https://github.com/stuttgart-things/claims/releases/download/v0.1.0/claims_0.1.0_linux_amd64.tar.gz
tar xvfz claim-machinery-api_0.1.1_linux_amd64.^Cr.gz
sudo mv claim-machinery-api /usr/bin/
sudo chmod +x /usr/bin/claims 
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
