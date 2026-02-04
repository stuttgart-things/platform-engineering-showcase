# KCL Crossplane VolumeClaim – Universal PVC Management via KCL

This document describes the KCL-based approach for managing PersistentVolumeClaims (PVCs) with Crossplane, using the claim-xplane-volumeclaim package. The structure and style follow the previous documentation examples.

## General

The claim-xplane-volumeclaim KCL package enables declarative, reusable, and parameterized creation of PVCs for any Kubernetes storage provider (e.g., Harvester, Longhorn, Rook-Ceph, standard StorageClasses). It leverages KCL's templating and parameterization to simplify and standardize PVC management.

## Why?

- **Reusability:** Define PVC logic once, use for all storage backends
- **Parameterization:** Easily switch between templates (demo, database, simple) and customize all relevant fields
- **Automation:** Integrate with CI/CD, GitOps, or developer self-service platforms
- **Flexibility:** Supports annotations, labels, selectors, access modes, volume modes, and more

## How does it work?

- **KCL Package:**
  - The main.k file provides logic to select and render different PVC templates based on parameters (templateName, useDbTemplate, etc.).
  - All relevant PVC fields (name, namespace, storage, storageClassName, accessModes, etc.) are parameterized and can be set via CLI or config.
- **Templates:**
  - Three main templates: demo, database, simple
  - Each template sets different defaults and metadata (e.g., labels, annotations, selectors)
- **ClaimTemplate:**
  - The templates/volumeclaim-simple.yaml file describes the available parameters and their defaults for the KCL package.

## Example: Run with Simple Template

```bash
kcl run oci://ghcr.io/stuttgart-things/claim-xplane-volumeclaim --tag 0.1.1 -D templateName=simple -D namespace=production -D storage=10Gi -D storageClassName=fast
```

## Example: Run with Demo Template

```bash
kcl run volume-claim.k -D templateName=demo
```

## Example: Run with Database Template

```bash
kcl run volume-claim.k -D templateName=database
```

## Example: Simple Template YAML Output

```yaml
apiVersion: resources.stuttgart-things.com/v1alpha1
kind: VolumeClaim
metadata:
  name: simple-storage
  namespace: production
spec:
  providerConfigRef: default-k8s
  annotations:
    description: "A simple persistent volume claim for application data"
  pvcName: app-data
  namespace: production
  storageClassName: fast
  storage: "10Gi"
```

## Example: Database Template YAML Output

```yaml
apiVersion: resources.stuttgart-things.com/v1alpha1
kind: VolumeClaim
metadata:
  name: db-pvc
  namespace: production
  annotations:
    example.com/managed-by: kcl-test
    backup.velero.io/backup-volumes: db-data
  labels:
    app: database
    tier: backend
    environment: production
spec:
  pvcName: db-pvc
  namespace: production
  storage: "100Gi"
  storageClassName: fast-ssd
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  providerConfigRef: default-k8s
  labels:
    app: database
    tier: backend
    environment: production
  selector:
    matchLabels:
      type: fast-ssd
      zone: us-west-2a
```

## Development & Testing

- **Parameter overview:** See templates/volumeclaim-simple.yaml for all available parameters and defaults
- **Try different templates:** Use the `-D templateName=...` flag to switch between demo, database, and simple
- **Integrate in pipelines:** KCL can be run in CI/CD or GitOps workflows for dynamic PVC generation

## Files

- `main.k` – Main KCL logic for template selection and rendering
- `templates/volumeclaim-simple.yaml` – Parameter schema and documentation
- `v1alpha1/resources_stuttgart_things_com_v1alpha1_volume_claim.k` – KCL schema for VolumeClaim

## Requirements

- KCL >= 0.7.x
- Crossplane >= v1.14.1
- Provider Kubernetes >= v1.2.0
