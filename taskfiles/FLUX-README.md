# Flux Taskfile

Interactive Taskfile for managing FluxInstances using the `kcl-flux-instance` KCL module from OCI registry.

## Prerequisites

- [Task](https://taskfile.dev/) installed
- [gum](https://github.com/charmbracelet/gum) installed for interactive prompts
- [kcl](https://kcl-lang.io/) installed
- kubectl configured with access to target cluster

## Installation

### Install gum
```bash
# macOS
brew install gum

# Linux
go install github.com/charmbracelet/gum@latest

# Or download binary from https://github.com/charmbracelet/gum/releases
```

### Install KCL
```bash
curl -fsSL https://kcl-lang.io/script/install-cli.sh | bash
```

## Available Tasks

### 🚀 render
Render FluxInstance Custom Resource with full interactive configuration.

```bash
task --taskfile taskfiles/flux.yaml render
```

**Features:**
- Interactive prompts for all configuration options
- Organized sections: Distribution, Git Sync, SOPS, Performance, Cluster
- Configuration summary before rendering
- Preview rendered YAML
- Saves output to specified file

**Prompts:**
- **Basic**: Name, Namespace
- **Distribution**: Flux version, Container registry
- **Git Sync**: Repository URL, branch, path, pull secret
- **SOPS**: Enable/disable, secret name
- **Performance**: Concurrent reconciliations, requeue interval
- **Cluster**: Multitenant mode, NetworkPolicy, domain
- **Reconciliation**: Interval, timeout
- **Output**: File path

### ⚡ quick
Quick setup with minimal prompts using production defaults.

```bash
task --taskfile taskfiles/flux.yaml quick
```

**Prompts (minimal):**
- Git repository URL (required)
- Path in repository
- FluxInstance name
- Output file

**Production Defaults:**
- SOPS: Enabled
- NetworkPolicy: Enabled
- Concurrent: 10
- Version: 2.4
- All other settings use module defaults

### 🎯 apply
Render and apply FluxInstance to Kubernetes cluster.

```bash
task --taskfile taskfiles/flux.yaml apply
```

**Workflow:**
1. Select kubeconfig from `~/.kube/`
2. Display selected cluster info
3. Check/create flux-system namespace
4. Run interactive render task
5. Confirm and apply to cluster
6. Show FluxInstance status

### 🗑️ delete
Delete FluxInstance from cluster.

```bash
task --taskfile taskfiles/flux.yaml delete
```

**Workflow:**
1. Select kubeconfig
2. List all FluxInstances
3. Select namespace
4. Select FluxInstance to delete
5. Confirm deletion
6. Delete resource

### 📊 status
Check FluxInstance status in cluster.

```bash
task --taskfile taskfiles/flux.yaml status
```

**Shows:**
- All FluxInstances across namespaces
- Flux pods in flux-system namespace
- Optional: Detailed description of selected FluxInstance

## Usage Examples

### Example 1: Render for Development Environment

```bash
task --taskfile taskfiles/flux.yaml render
```

Then provide:
- Name: `flux-dev`
- Namespace: `flux-dev`
- Git URL: `https://github.com/my-org/dev-configs.git`
- Git Path: `dev`
- SOPS: `false`
- NetworkPolicy: `false`

### Example 2: Quick Production Setup

```bash
task --taskfile taskfiles/flux.yaml quick
```

Provide only:
- Git URL: `https://github.com/my-org/prod-configs.git`
- Path: `clusters/production`
- Name: `flux-prod`

All other settings use secure production defaults.

### Example 3: Full Production Deployment

```bash
task --taskfile taskfiles/flux.yaml apply
```

1. Select your production kubeconfig
2. Configure with full interactive prompts:
   - Name: `flux-prod`
   - Namespace: `flux-system`
   - Version: `2.4`
   - Git URL: `https://github.com/my-org/infrastructure.git`
   - Git Path: `clusters/prod/apps`
   - SOPS: `true`
   - Concurrent: `20`
   - Multitenant: `true`
3. Review configuration
4. Apply to cluster
5. Monitor deployment

### Example 4: Check Flux Status

```bash
task --taskfile taskfiles/flux.yaml status
```

Select cluster and optionally view detailed status of specific FluxInstance.

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `name` | `flux` | FluxInstance name |
| `namespace` | `flux-system` | Target namespace |
| `version` | `2.4` | Flux version |
| `registry` | `ghcr.io/fluxcd` | Container registry |
| `gitUrl` | - | Git repository URL (required) |
| `gitRef` | `refs/heads/main` | Git branch/tag |
| `gitPath` | `clusters/production` | Path in repository |
| `gitPullSecret` | `git-token-auth` | Secret for Git auth |
| `sopsEnabled` | `true` | Enable SOPS decryption |
| `sopsSecretName` | `sops-age` | SOPS secret name |
| `concurrent` | `10` | Concurrent reconciliations |
| `requeueDependency` | `5s` | Requeue interval |
| `multitenant` | `false` | Multitenant mode |
| `networkPolicy` | `true` | Enable NetworkPolicy |
| `domain` | `cluster.local` | Cluster domain |
| `reconcileEvery` | `1h` | Reconciliation interval |
| `reconcileTimeout` | `5m` | Reconciliation timeout |

## OCI Package Information

- **Package**: `oci://ghcr.io/stuttgart-things/kcl-flux-instance`
- **Version**: `0.1.1`
- **Registry**: GitHub Container Registry (GHCR)

The Taskfile automatically pulls the latest version from the OCI registry.

## Output Files

Default output locations:
- **Rendered YAML**: `/tmp/flux-instance.yaml`
- **Kubeconfig**: Files in `~/.kube/`

You can customize the output path during the interactive prompts.

## Troubleshooting

### KCL module not found
```bash
# Manually pull the module
kcl mod metadata oci://ghcr.io/stuttgart-things/kcl-flux-instance --tag 0.1.1
```

### gum not found
```bash
# Install gum
brew install gum  # macOS
# or
go install github.com/charmbracelet/gum@latest
```

### kubectl context issues
```bash
# List available contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>
```

### FluxInstance not appearing
```bash
# Check if CRD exists
kubectl get crd fluxinstances.fluxcd.controlplane.io

# Check Flux operator logs
kubectl logs -n flux-system -l app=flux-operator
```

## Tips

1. **Use quick task** for fast deployments with sensible defaults
2. **Use render task** when you need full control over configuration
3. **Always review** the configuration summary before applying
4. **Check status** after deployment to ensure Flux is running
5. **Save rendered YAML** for GitOps workflows

## Integration with GitOps

You can use the `render` task to generate FluxInstance manifests and commit them to your GitOps repository:

```bash
# Render FluxInstance
task --taskfile taskfiles/flux.yaml render

# Output saved to /tmp/flux-instance.yaml

# Copy to GitOps repo
cp /tmp/flux-instance.yaml ~/my-gitops-repo/clusters/prod/flux/

# Commit and push
cd ~/my-gitops-repo
git add .
git commit -m "feat: add FluxInstance configuration"
git push
```

## Related Documentation

- [KCL Flux Instance Module](https://github.com/stuttgart-things/kcl/tree/main/kcl-flux-instance)
- [Flux Documentation](https://fluxcd.io/flux/)
- [Task Documentation](https://taskfile.dev/)
- [Gum Documentation](https://github.com/charmbracelet/gum)
