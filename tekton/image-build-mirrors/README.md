# platform-engineering-showcase/tekton/image-mirrors

## EXPORT (INTERNET FACING)

<details><summary>ANALYZE PROJECT STRCUTURE</summary>

```bash
sh scripts/analyze-project-dir.sh --dir _example
```

</details>

<details><summary>ANALYZE IMAGES FROM K8S NAMESPACE</summary>

```bash
sh scripts/analyze-images-namespace.sh --namespace tekton-operator
```

</details>

<details><summary>ANALYZE HELM CHART</summary>

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/

sh scripts/analyze-helm-chart.sh \
--name kyverno \
--charturl kyverno/kyverno \
--version 3.5.1
```

</details>

<details><summary>DOWLOAD HELM CHART</summary>

```bash
# OPTION1: CHART REPO
helm repo add kyverno https://kyverno.github.io/kyverno/
helm pull kyverno/kyverno --version 3.5.1

# OPTION2: OCI-REPO
helm pull oci://ghcr.io/stuttgart-things/tekton/tekton --version 0.77.0
```

</details>

<details><summary>EXPORT CONTAINER-IMAGES</summary>

```bash
sh scripts/export-container-images.sh \
  --images "python:3.13.7-alpine,redis" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name python_redis_images
```

</details>

<details><summary>EXPORT APK-PACKAGES</summary>

```bash
sh scripts/export-apk-packages.sh \
  --image "alpine:3.20" \
  --apk-packages "bash,curl,git" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name alpine20_apks
```

</details>

<details><summary>EXPORT PIP-PACKAGES</summary>

```bash
sh scripts/export-pip-packages.sh \
  --image python:3.13.7-alpine \
  --pip-packages "flask,requests,sqlalchemy" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name flask_bundle
```

</details>

## IMPORT (AIR-GAPPED)

<details><summary>IMPORT CONTAINER-IMAGES</summary>

```bash
sh scripts/import-container-images.sh \
  --runtime docker \
  --input-dir /tmp \
  --archive-name python_redis_images
```

</details>

<details><summary>IMPORT PACKAGES (APK OR PIP)</summary>

```bash
sh scripts/import-packages.sh \
  --zip-path /tmp/pip-flask_bundle.zip \
  --pvc-path /mnt/pvc \
  --force
```

</details>

```bash
sh scripts/push-tar-image.sh \
  --tar-file ./python_app.tar \
  --target-registry registry.example.com \
  --namespace my-namespace \
  --target-image python_app:1.0.0 \
  --username admin \
  --password secret \
  --pod-name skopeo-temp \
  --image bdwyertech/skopeo:1.16.1
```

## REQURIEMENNTS

<details><summary>CREATE CLUSTER</summary>

### OPTION: KIND


### OPTION: VCLUSTER


</details>

<details><summary>DEPLOY APK+PIP MIRROR</summary>


</details>


<details><summary>DEPLOY TEKTON</summary>


</details>
