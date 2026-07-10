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
step-by-step confirmations). It's structured in three tiers so it scales to multiple cluster types:

| Tier | Task | What |
|------|------|------|
| **substrate** | `create-kind-cluster` | kind cluster + cilium CNI |
| **foundation** | `deploy-foundation` | cert-manager → sops-secrets-operator (+ age key) → openebs |
| **profile** | `profile-machinery` | tekton → crossplane → Configuration packages → capabilities |

```bash
# one guided run: substrate → foundation → choose profile(s)
task bootstrap

# …or run any tier / building block on its own
task create-kind-cluster
task deploy-foundation
task profile-machinery
```

The **machinery** profile makes the cluster a VM builder: apply a `NativeVsphereVM` XR and
Crossplane provisions a VM in vSphere (labul/labda), optionally running an Ansible base-OS
playbook via Tekton. `deploy-capabilities` can enable multiple environments at once
(labul **and** labda on one cluster). Add a new cluster type as a `profile-<name>` task and
list it in `bootstrap` — substrate + foundation stay unchanged.

**Building-block tasks** (interactive, reusable standalone): `deploy-cert-manager`,
`deploy-sops`, `deploy-openebs`, `deploy-tekton`, `deploy-crossplane`, `deploy-configurations`,
`deploy-capabilities`. List everything with `task` (or `task do`).

> The `sops` credentials backend needs the project age private key in your environment —
> `export SOPS_AGE_KEY=…` before `deploy-sops` / `deploy-capabilities`.

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
