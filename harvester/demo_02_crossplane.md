
# Crossplane VolumeClaim – Universal PVC Management for Kubernetes

This document describes the Crossplane configuration for managing PersistentVolumeClaims (PVCs) across different storage backends. It follows the format of demo_01_packer.md and refers to the configuration in crossplane/configurations/k8s/volume-claim.

## General

With this Crossplane configuration, PVCs can be defined declaratively and reused for any Kubernetes storage provider (e.g., Harvester, Longhorn, Rook-Ceph, standard StorageClasses). It abstracts the complexity of PVC creation and enables unified management—regardless of the underlying storage.

## Why?

- **Reusability:** Define PVC logic once and use it for all storage backends
- **Abstraction:** Hides complexity and differences between storage providers
- **Automation:** Easy integration into CI/CD, GitOps, and self-service platforms
- **Flexibility:** Supports labels, annotations, volume modes, data sources, etc.

## How does it work?

The configuration defines a user-friendly CRD type `VolumeClaim` and a Crossplane Composition that generates a native PVC from it. The main components:

- **CRD & Composition:**
  - `apis/composition.yaml` contains the pipeline logic (Go templating) that creates a PVC from a `VolumeClaim` object.
  - Flexible parameter passing for storage class, size, annotations, labels, etc.
- **Functions:**
  - `function-go-templating` renders the PVC manifest template.
  - `function-auto-ready` automatically sets the status as soon as the PVC is ready.
- **Examples:**
  - `examples/claim.yaml` shows a simple VolumeClaim resource.

## Example: Simple VolumeClaim Resource

```yaml
apiVersion: resources.stuttgart-things.com/v1alpha1
kind: VolumeClaim
metadata:
  name: simple-storage
  namespace: default
spec:
  providerConfigRef: in-cluster
  annotations:
    description: "A simple persistent volume claim for application data"
  pvcName: app-data
  namespace: default
  storageClassName: standard
  storage: "1Gi"
```

## Example: Harvester VM Disk

```yaml
apiVersion: resources.stuttgart-things.com/v1alpha1
kind: VolumeClaim
metadata:
  name: ubuntu-vm-disk
spec:
  providerConfigRef: kubernetes-provider
  pvcName: ubuntu-vm-root
  namespace: vms
  storageClassName: longhorn-ubuntu-22.04
  storage: "100Gi"
  volumeMode: Block
  annotations:
    harvesterhci.io/imageId: "harvester-public/ubuntu-22.04"
    description: "Ubuntu 22.04 VM root disk"
  labels:
    app: web-server
    environment: production
```

## Development & Testing

- **Test rendering:**
  ```bash
  crossplane render examples/claim.yaml \
    apis/composition.yaml \
    examples/functions.yaml \
    --include-function-results
  ```
- **Trace status:**
  ```bash
  crossplane beta trace volumeclaim simple-storage
  ```

## Files

- `apis/composition.yaml` – Crossplane composition definition
- `examples/claim.yaml` – Example VolumeClaim
- `examples/functions.yaml` – Function definitions

## Requirements

- Crossplane >= v1.14.1
- Provider Kubernetes >= v1.2.0
- Function Go Templating >= v0.11.3
- Function Auto Ready >= v0.6.0
