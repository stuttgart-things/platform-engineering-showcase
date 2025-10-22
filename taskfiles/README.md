# Taskfiles Documentation

Interactive automation tasks for platform engineering workflows.

## Table of Contents

- [Requirements](#requirements)
- [Flux Taskfile](#flux-taskfile)
- [Environment Variables](#environment-variables)

---

## Requirements

<details><summary><b>📦 Install Homebrew</b></summary>

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

</details>

<details><summary><b>⚙️ Install Task & Gum</b></summary>

```bash
brew install go-task/tap/go-task gum
```

**Alternative installations:**

```bash
# Task
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Gum
go install github.com/charmbracelet/gum@latest
```

</details>

<details><summary><b>🔧 Install Kubernetes Tools</b></summary>

```bash
brew install cilium-cli k9s kubectl helm helmfile
```

**Or individually:**

```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# KCL
curl -fsSL https://kcl-lang.io/script/install-cli.sh | bash
```

</details>

---

## Flux Taskfile

Interactive taskfile for managing FluxCD instances using the `kcl-flux-instance` KCL module.

### Overview

**Location**: `taskfiles/flux.yaml`
**OCI Package**: `oci://ghcr.io/stuttgart-things/kcl-flux-instance:0.2.1`
**Module Documentation**: [kcl-flux-instance](https://github.com/stuttgart-things/kcl/tree/main/kcl-flux-instance)

### Available Tasks

<details><summary><b>🚀 render - Interactive FluxInstance Configuration</b></summary>

Render FluxInstance Custom Resource with full interactive configuration.

```bash
task --taskfile taskfiles/flux.yaml render
```

**Features:**
- Secret rendering option (Git credentials + SOPS key)
- Environment variable support (`GITHUB_USER`, `GITHUB_TOKEN`, `SOPS_AGE_KEY`)
- Interactive prompts for all configuration options
- Configuration summary before rendering
- Preview rendered YAML
- Choose: Apply to cluster, Save to file, or Cancel

**Workflow:**
1. **Namespace** configuration
2. **Secret Rendering** (optional)
   - Git authentication secret (username/password)
   - SOPS decryption secret (AGE key)
3. **SOPS Configuration**
4. **Distribution Settings** (Flux version)
5. **Git Sync Configuration** (repository, branch, path)
6. **Performance Settings** (concurrent, requeue)
7. **Cluster Settings** (multitenant, network policy)
8. **Reconciliation Settings** (interval, timeout)
9. **Summary & Confirmation**
10. **Preview YAML**
11. **Action**: Apply to cluster or Save to file

**Output:**
- Default file: `/tmp/${CLUSTER_NAME}-flux-instance.yaml`
- Clean YAML with proper document separators (`---`)

</details>

<details><summary><b>🗑️ delete - Remove FluxInstance</b></summary>

Delete FluxInstance from cluster.

```bash
task --taskfile taskfiles/flux.yaml delete
```

**Workflow:**
1. Select kubeconfig from `~/.kube/`
2. List all FluxInstances across namespaces
3. Select namespace
4. Select FluxInstance to delete
5. Confirm deletion with warning
6. Delete resource

</details>

<details><summary><b>📊 status - Check FluxInstance Status</b></summary>

Check FluxInstance status in cluster.

```bash
task --taskfile taskfiles/flux.yaml status
```

**Shows:**
- All FluxInstances across namespaces
- Flux pods in flux-system namespace
- Optional: Detailed description of selected FluxInstance

</details>

### Configuration Options

<details><summary><b>📋 All Configuration Parameters</b></summary>

| Parameter | Default | Description |
|-----------|---------|-------------|
| `name` | `flux` | FluxInstance name (fixed) |
| `namespace` | `flux-system` | Target namespace |
| `version` | `2.4` | Flux version |
| `registry` | `ghcr.io/fluxcd` | Container registry (fixed) |
| `gitUrl` | - | Git repository URL (required) |
| `gitRef` | `refs/heads/main` | Git branch/tag |
| `gitPath` | `clusters/${CLUSTER_NAME}` | Path in repository |
| `gitPullSecret` | `git-token-auth` | Secret for Git auth |
| `renderSecrets` | `false` | Render Kubernetes Secrets |
| `gitUsername` | `$GITHUB_USER` | Git username (if renderSecrets=true) |
| `gitPassword` | `$GITHUB_TOKEN` | Git password/token (if renderSecrets=true) |
| `sopsEnabled` | `true` | Enable SOPS decryption |
| `sopsSecretName` | `sops-age` | SOPS secret name |
| `sopsAgeKey` | `$SOPS_AGE_KEY` | SOPS AGE key (if renderSecrets=true) |
| `concurrent` | `10` | Concurrent reconciliations |
| `requeueDependency` | `5s` | Requeue interval |
| `multitenant` | `false` | Multitenant mode |
| `networkPolicy` | `true` | Enable NetworkPolicy |
| `domain` | `cluster.local` | Cluster domain |
| `reconcileEvery` | `1h` | Reconciliation interval |
| `reconcileTimeout` | `5m` | Reconciliation timeout |

</details>

### Usage Examples

<details><summary><b>🔹 Example 1: Development Setup (No Secrets)</b></summary>

```bash
task --taskfile taskfiles/flux.yaml render
```

**Configuration:**
- Render Secrets: `false`
- Cluster: `dev-k8s`
- Git URL: `https://github.com/my-org/dev-configs.git`
- Git Path: `clusters/dev-k8s`
- SOPS: `false`
- NetworkPolicy: `false`

**Output:** `/tmp/dev-k8s-flux-instance.yaml`

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: FluxInstance
metadata:
  name: flux
  namespace: flux-system
spec:
  # ... configuration
```

</details>

<details><summary><b>🔹 Example 2: Production with Secrets (Environment Variables)</b></summary>

**Setup:**
```bash
# Set environment variables
export GITHUB_USER="patrick-hermann-sva"
export GITHUB_TOKEN="ghp_..."
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."

# Run taskfile
task --taskfile taskfiles/flux.yaml render
```

**Configuration:**
- Render Secrets: `true` ← Automatically uses env vars!
- Cluster: `production`
- Git URL: `https://github.com/my-org/infrastructure.git`
- Git Path: `clusters/production`
- SOPS: `true`
- Concurrent: `20`

**Output:** `/tmp/production-flux-instance.yaml`

```yaml
apiVersion: fluxcd.controlplane.io/v1
kind: FluxInstance
# ...
---
apiVersion: v1
kind: Secret
metadata:
  name: git-token-auth
  namespace: flux-system
stringData:
  username: patrick-hermann-sva
  password: ghp_...
---
apiVersion: v1
kind: Secret
metadata:
  name: sops-age
  namespace: flux-system
stringData:
  age.agekey: AGE-SECRET-KEY-1...
```

**Apply:**
```bash
kubectl apply -f /tmp/production-flux-instance.yaml
```

</details>

<details><summary><b>🔹 Example 3: Apply Directly to Cluster</b></summary>

```bash
task --taskfile taskfiles/flux.yaml render
```

**Workflow:**
1. Configure FluxInstance interactively
2. Preview YAML
3. Choose: **"Apply to cluster"**
4. Select kubeconfig
5. Confirm namespace creation (if needed)
6. Apply resources
7. Check FluxInstance status

</details>

---

## Environment Variables

The Flux taskfile supports reading secrets from environment variables for automation and CI/CD.

### Supported Variables

<details><summary><b>🔑 Environment Variable Reference</b></summary>

| Variable | Purpose | Used For |
|----------|---------|----------|
| `GITHUB_USER` | Git username | Default for Git authentication username |
| `GITHUB_TOKEN` | Git personal access token | Auto-fills Git password/token (no prompt) |
| `SOPS_AGE_KEY` | SOPS AGE private key | Auto-fills SOPS decryption key (no prompt) |

**Detection:**
The taskfile automatically detects and displays checkmarks for available environment variables:

```
✓ Found GITHUB_USER environment variable
✓ Found GITHUB_TOKEN environment variable
✓ Found SOPS_AGE_KEY environment variable
```

</details>

### Usage Patterns

<details><summary><b>💻 Interactive with Environment Variables</b></summary>

```bash
# Set environment variables
export GITHUB_USER="patrick-hermann-sva"
export GITHUB_TOKEN="ghp_..."
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."

# Run interactive taskfile
task --taskfile taskfiles/flux.yaml render
```

**What happens:**
1. ✓ Shows checkmarks for detected variables
2. ✓ Uses `GITHUB_USER` as default for username prompt
3. ✓ Automatically uses `GITHUB_TOKEN` (no password prompt!)
4. ✓ Automatically uses `SOPS_AGE_KEY` (no key prompt!)

</details>

<details><summary><b>🔐 Security Best Practices</b></summary>

### 1. Never Commit Secrets

```bash
# ❌ DON'T DO THIS
export GITHUB_TOKEN="ghp_RealTokenHere123"
git add .env

# ✅ DO THIS
echo ".env" >> .gitignore
echo "*.secret" >> .gitignore
```

### 2. Use Secure File Storage

```bash
# Store in secure file
cat > ~/.secrets/flux-env << 'EOF'
export GITHUB_USER="patrick-hermann-sva"
export GITHUB_TOKEN="ghp_DevToken123"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1DEV..."
EOF

chmod 600 ~/.secrets/flux-env

# Load when needed
source ~/.secrets/flux-env

# Run taskfile
task --taskfile taskfiles/flux.yaml render
```

### 3. Temporary Secrets (Not in History)

```bash
# Set secrets only for current command
GITHUB_TOKEN="ghp_..." SOPS_AGE_KEY="AGE-..." task --taskfile taskfiles/flux.yaml render
```

### 4. Use Secret Management Tools

```bash
# Load from Vault
export GITHUB_TOKEN=$(vault kv get -field=token secret/flux/github)
export SOPS_AGE_KEY=$(vault kv get -field=key secret/flux/sops)

# Or from encrypted file with SOPS
export GITHUB_TOKEN=$(sops -d secrets.yaml | yq e '.github.token' -)
export SOPS_AGE_KEY=$(sops -d secrets.yaml | yq e '.sops.key' -)
```

</details>

<details><summary><b>🤖 CI/CD Integration</b></summary>

### GitHub Actions

```yaml
name: Deploy Flux
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup environment
        run: |
          echo "GITHUB_USER=${{ secrets.FLUX_GIT_USER }}" >> $GITHUB_ENV
          echo "GITHUB_TOKEN=${{ secrets.FLUX_GIT_TOKEN }}" >> $GITHUB_ENV
          echo "SOPS_AGE_KEY=${{ secrets.FLUX_SOPS_KEY }}" >> $GITHUB_ENV

      - name: Install dependencies
        run: |
          curl -sL https://taskfile.dev/install.sh | sh
          brew install gum kcl kubectl

      - name: Deploy Flux
        run: |
          task --taskfile taskfiles/flux.yaml render
```

### GitLab CI

```yaml
deploy-flux:
  stage: deploy
  variables:
    GITHUB_USER: $FLUX_GIT_USER
    GITHUB_TOKEN: $FLUX_GIT_TOKEN
    SOPS_AGE_KEY: $FLUX_SOPS_KEY
  script:
    - task --taskfile taskfiles/flux.yaml render
```

</details>

<details><summary><b>🧪 Verification Commands</b></summary>

```bash
# Check all GITHUB variables
printenv | grep GITHUB_

# Check SOPS variable
printenv | grep SOPS_

# Check if variables are set (without showing values)
[ -n "$GITHUB_USER" ] && echo "✓ GITHUB_USER is set" || echo "✗ GITHUB_USER not set"
[ -n "$GITHUB_TOKEN" ] && echo "✓ GITHUB_TOKEN is set" || echo "✗ GITHUB_TOKEN not set"
[ -n "$SOPS_AGE_KEY" ] && echo "✓ SOPS_AGE_KEY is set" || echo "✗ SOPS_AGE_KEY not set"
```

</details>

### Multi-Environment Setup

<details><summary><b>🌍 Managing Multiple Environments</b></summary>

```bash
# ~/.secrets/flux-dev.env
export GITHUB_USER="dev-bot"
export GITHUB_TOKEN="ghp_DevToken"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1DEV..."

# ~/.secrets/flux-staging.env
export GITHUB_USER="staging-bot"
export GITHUB_TOKEN="ghp_StagingToken"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1STAGING..."

# ~/.secrets/flux-prod.env
export GITHUB_USER="prod-bot"
export GITHUB_TOKEN="ghp_ProdToken"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1PROD..."

# Use based on environment
source ~/.secrets/flux-${ENVIRONMENT}.env
task --taskfile taskfiles/flux.yaml render
```

**Example:**
```bash
# Deploy to development
ENVIRONMENT=dev source ~/.secrets/flux-${ENVIRONMENT}.env
task --taskfile taskfiles/flux.yaml render

# Deploy to production
ENVIRONMENT=prod source ~/.secrets/flux-${ENVIRONMENT}.env
task --taskfile taskfiles/flux.yaml render
```

</details>

---

## Troubleshooting

<details><summary><b>❌ KCL module not found</b></summary>

```bash
# Manually pull the module
kcl mod metadata oci://ghcr.io/stuttgart-things/kcl-flux-instance --tag 0.2.1
```

</details>

<details><summary><b>❌ gum not found</b></summary>

```bash
# Install gum
brew install gum  # macOS

# Linux
go install github.com/charmbracelet/gum@latest

# Or download binary
wget https://github.com/charmbracelet/gum/releases/latest/download/gum_Linux_x86_64.tar.gz
tar xzf gum_Linux_x86_64.tar.gz
sudo mv gum /usr/local/bin/
```

</details>

<details><summary><b>❌ Environment variables not being used</b></summary>

```bash
# Ensure variables are exported (not just set)
export GITHUB_TOKEN="..."  # ✅ Correct
GITHUB_TOKEN="..."         # ❌ Won't work (not exported)

# Check if exported
env | grep GITHUB_TOKEN

# Make sure to source files (not execute)
source ~/.secrets/flux-env  # ✅ Correct
bash ~/.secrets/flux-env    # ❌ Won't work (runs in subshell)
```

</details>

<details><summary><b>❌ ParseIntError for concurrent parameter</b></summary>

This is fixed in version 0.2.1. Update your taskfile:

```yaml
FLUX_INSTANCE_VERSION: "0.2.1"
```

Or manually update the module:
```bash
kcl mod add oci://ghcr.io/stuttgart-things/kcl-flux-instance --tag 0.2.1
```

</details>

<details><summary><b>❌ FluxInstance not appearing</b></summary>

```bash
# Check if CRD exists
kubectl get crd fluxinstances.fluxcd.controlplane.io

# Check Flux operator logs
kubectl logs -n flux-system -l app=flux-operator

# Verify namespace
kubectl get fluxinstance --all-namespaces
```

</details>

---

## Tips & Best Practices

<details><summary><b>💡 Workflow Tips</b></summary>

1. **Set environment variables** for automation (CI/CD, repeated deployments)
2. **Use `/tmp/` for output** - it's cleaned on reboot and keeps workspace clean
3. **Review configuration summary** before applying to prevent mistakes
4. **Check status** after deployment to ensure Flux is running correctly
5. **Save rendered YAML** to GitOps repo for version control

</details>

<details><summary><b>🔄 GitOps Integration</b></summary>

```bash
# Render FluxInstance
task --taskfile taskfiles/flux.yaml render

# Output saved to /tmp/production-flux-instance.yaml

# Copy to GitOps repo
cp /tmp/production-flux-instance.yaml ~/my-gitops-repo/clusters/prod/flux/

# Commit and push
cd ~/my-gitops-repo
git add clusters/prod/flux/production-flux-instance.yaml
git commit -m "feat: add FluxInstance configuration for production"
git push

# Flux will reconcile automatically
```

</details>

---

## Related Documentation

- **KCL Module**: [kcl-flux-instance](https://github.com/stuttgart-things/kcl/tree/main/kcl-flux-instance)
- **Secret Rendering**: [SECRETS.md](https://github.com/stuttgart-things/kcl/blob/main/kcl-flux-instance/SECRETS.md)
- **Flux Documentation**: [fluxcd.io](https://fluxcd.io/flux/)
- **Task Documentation**: [taskfile.dev](https://taskfile.dev/)
- **Gum Documentation**: [github.com/charmbracelet/gum](https://github.com/charmbracelet/gum)
- **KCL Documentation**: [kcl-lang.io](https://kcl-lang.io/)

---

## Quick Reference

```bash
# Interactive full configuration
task --taskfile taskfiles/flux.yaml render

# Delete FluxInstance
task --taskfile taskfiles/flux.yaml delete

# Check status
task --taskfile taskfiles/flux.yaml status

# With environment variables
export GITHUB_USER="..." GITHUB_TOKEN="..." SOPS_AGE_KEY="..."
task --taskfile taskfiles/flux.yaml render

# Check what environment variables are set
printenv | grep -E "(GITHUB_|SOPS_)"
```
