# stuttgart-things/platform-engineering-showcase

Composable infrastructure for fast-moving teams

| Category    | Description           |
|-------------|-----------------------|
| 📦 [DAGGER](./dagger/README.md)      | Programmable CI/CD engine for running pipelines in containers using Dagger modules |
| 🛠️ [BACKSTAGE](./backstage/README.md) | Open platform for developer portals, service catalog, docs, and internal tools |
| 🛳️ [CROSSPLANE](./crossplane/README.md) | Kubernetes add-on for infrastructure and app management via declarative APIs |
| 🧑‍🔬 [KIND](./kind/README.md)        | Local Kubernetes clusters with Docker nodes, ideal for testing and CI workflows |
| 🚦 [ARGOCD](./argocd/README.md)      | GitOps continuous delivery for Kubernetes (see ArgoCD folder) |
| 🚚 [KARGO](./kargo/README.md)        | Progressive delivery and GitOps for Kubernetes workloads |
| 🛡️ [KEYCLOAK](./keycloak/README.md)  | Identity and access management for modern applications |

## Cluster Bootstrap

Build a cluster from scratch with the interactive [`Taskfile`](./Taskfile.yaml) (gum-driven,
step-by-step confirmations). Two tiers: a **substrate** (any cluster type) and a **profile**
(the cluster TYPE). `task bootstrap` runs substrate → chosen profile(s); each profile installs
exactly the platform pieces it needs.

```bash
task bootstrap              # substrate → gum-choose profile(s) [machinery, …]
```

### Machinery cluster (VM builder)

`task profile-machinery` runs steps 2–6 below in order (or run any task standalone):

| # | Task | What it installs |
|---|------|------------------|
| 1 | `create-kind-cluster` | **substrate** — kind cluster + cilium CNI (free-port defaults, collision guard) |
| 2 | `deploy-sops-operator` | cert-manager (only if missing) + sops-secrets-operator + age-key Secret (`crossplane-system`, `tekton-ci`) |
| 3 | `deploy-tekton` | OpenEBS local-pv storage (gum-confirmed) + Tekton operator/pipeline |
| 4 | `deploy-crossplane` | Crossplane core → providers → functions/config → provider-configs (waited, no CRD race) |
| 5 | `deploy-configurations` | vspherevm/proxmoxvm Configuration package(s) + wait for their provider CRDs |
| 6 | `deploy-capabilities` | per-env EnvironmentConfig + ClusterProviderConfig + creds (env-map `labul`/`labda`; backend `none`\|`eso`\|`sops`) |

Once built, apply a `NativeVsphereVM` XR with `spec.environmentConfig: labul` and Crossplane
provisions a VM in vSphere; add `spec.ansible.enabled: true` to run an Ansible base-OS playbook
via Tekton. `deploy-capabilities` can enable **multiple environments at once** (labul **and**
labda on one cluster). Add a new cluster type as a `profile-<name>` task and list it in `bootstrap`.

> The `sops` credentials backend needs the project age private key in your environment —
> `export SOPS_AGE_KEY=…` before `deploy-sops-operator` / `deploy-capabilities`.

Tear down with `task destroy-kind-cluster` — it warns on orphaned Crossplane-managed VMs and
prunes the leftover kubeconfig.

## AUTHORS

```yaml
---
project:
  name: platform-engineering-showcase
  description: composable infrastructure for fast-moving teams
  license: Apache
  created: 2025-08-01
  tags: [devops, dagger, backstage, crossplane, kubernetes]
  maintainers:
    - name: Patrick Hermann
      handle: stuttgart-things
      location: DE
      roles: [lead, design, integrator]
```
