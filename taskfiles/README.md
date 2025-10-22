# Taskfiles Documentation

Interactive automation tasks for platform engineering workflows.

## Table of Contents

- [Requirements](#requirements)
- [Flux Taskfile](#flux-taskfile)
- [Dagger Shell Taskfile](#dagger-shell-taskfile)
- [Git Taskfile](#git-taskfile)
- [K3s Taskfile](#k3s-taskfile)
- [Tekton Runs Taskfile](#tekton-runs-taskfile)

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

---

## Dagger Shell Taskfile

Interactive taskfile for creating and managing Dagger container environments with custom base images and packages.

### Overview

**Location**: `taskfiles/dagger-shell.yaml`
**Purpose**: Quick containerized development environments using Dagger

### Available Tasks

<details><summary><b>🐳 run-terminal - Interactive Container Terminal</b></summary>

Launch an interactive terminal in a containerized environment with customizable base image and packages.

```bash
task --taskfile taskfiles/dagger-shell.yaml run-terminal
```

**Features:**
- Choice of predefined base images or custom image
- Optional package installation
- Multiple package manager support
- Pre-defined common packages + custom packages
- Interactive multi-select for packages

**Workflow:**
1. **Select Base Image:**
   - `cgr.dev/chainguard/wolfi-base` (Chainguard Wolfi)
   - `alpine`
   - `ubuntu:22.04`
   - `debian:bookworm`
   - `fedora:latest`
   - Custom image (enter manually)

2. **Add Packages (Optional):**
   - Confirm if you want to add packages

3. **Select Package Manager:**
   - `apk add` (Alpine)
   - `apt-get update && apt-get install -y` (Debian/Ubuntu)
   - `dnf install -y` (Fedora)
   - `yum install -y` (RHEL/CentOS)
   - Custom command

4. **Select Packages:**
   - Multi-select from common packages: `curl`, `git`, `vim`, `htop`, `wget`, `bash`, `jq`, `make`, `gcc`, `python3`, `nodejs`, `go`
   - Add custom packages

5. **Launch Terminal:**
   - Dagger creates and launches the container
   - Interactive shell ready to use

**Examples:**

```bash
# Alpine with basic tools
# Select: alpine → Add packages: yes → apk add → curl, git, vim

# Ubuntu for Python development
# Select: ubuntu:22.04 → Add packages: yes → apt-get → python3, git, make

# Chainguard minimal
# Select: cgr.dev/chainguard/wolfi-base → No packages
```

</details>

<details><summary><b>📦 publish-image - Build and Publish Container Image</b></summary>

Build a container image with custom packages and publish to a registry.

```bash
task --taskfile taskfiles/dagger-shell.yaml publish-image
```

**Features:**
- Reuses base image and package selection
- Multiple registry support (ttl.sh, docker.io, ghcr.io, gcr.io, custom)
- Auto-generates image name from base image
- Timestamp-based tagging

**Workflow:**
1. **Base Image & Packages** (same as run-terminal)
2. **Select Registry:**
   - `ttl.sh` (temporary images, auto-expire)
   - `docker.io` (Docker Hub)
   - `ghcr.io` (GitHub Container Registry)
   - `gcr.io` (Google Container Registry)
   - Custom registry

3. **Image Configuration:**
   - Repository name (default: `stuttgart-things`)
   - Image name (auto-extracted from base image or custom)
   - Tag (default: `YYYYMMDD-HHMMSS` timestamp)

4. **Build & Push:**
   - Dagger builds the image
   - Publishes to selected registry
   - Displays final image reference

**Examples:**

```bash
# Quick test image (expires in 24h)
# ttl.sh/stuttgart-things/dev-env:20250101-120000

# Publish to GitHub Container Registry
# ghcr.io/stuttgart-things/python-dev:20250101-120000

# Custom registry
# registry.example.com/team/build-env:v1.0.0
```

**Output:**
```
Publishing to: ttl.sh/stuttgart-things/alpine-dev:20250122-143000
✅ Image published: ttl.sh/stuttgart-things/alpine-dev:20250122-143000
```

</details>

### Use Cases

<details><summary><b>💡 Common Scenarios</b></summary>

**1. Quick Debugging Environment:**
```bash
task --taskfile taskfiles/dagger-shell.yaml run-terminal
# Alpine + curl, wget, vim → troubleshoot network issues
```

**2. Temporary Build Environment:**
```bash
task --taskfile taskfiles/dagger-shell.yaml run-terminal
# Ubuntu + gcc, make, git → compile a project
```

**3. Create Custom CI Base Image:**
```bash
task --taskfile taskfiles/dagger-shell.yaml publish-image
# Chainguard Wolfi + kubectl, helm, kcl → publish to ghcr.io
```

**4. Python Development Container:**
```bash
task --taskfile taskfiles/dagger-shell.yaml run-terminal
# Ubuntu + python3, pip, git → development work
```

</details>

---

## Git Taskfile

Interactive taskfile for Git workflow automation with conventional commits and pull request management.

### Overview

**Location**: `taskfiles/git.yaml`
**Purpose**: Streamline Git operations, enforce commit conventions, manage PRs

### Available Tasks

<details><summary><b>💾 commit - Commit & Push Changes</b></summary>

Interactive commit workflow with conventional commit support and change review.

```bash
task --taskfile taskfiles/git.yaml commit
```

**Features:**
- Pre-commit hook execution
- Git status review before commit
- Conventional commit message templates
- Custom commit messages with file context
- Automatic push to origin

**Workflow:**
1. **Pre-commit Checks:** Runs `pre-commit` hooks (formatting, linting, etc.)
2. **Set Upstream:** Links branch to remote
3. **Pull Latest:** Syncs with remote branch
4. **Review Changes:** Shows `git status`
5. **Confirm Commit:** Review changes, confirm or cancel
6. **Commit Message:**
   - `CUSTOM MESSAGE` - Enter your own message (shows changed files)
   - `feat: <branch-name>` - New feature
   - `fix: <branch-name>` - Bug fix
   - `BREAKING CHANGE: <branch-name>` - Breaking change
7. **Push:** Automatic push to origin

**Examples:**

```bash
# Feature branch workflow
git checkout -b feat/add-flux-secrets
# ... make changes ...
task --taskfile taskfiles/git.yaml commit
# Select: "feat: feat/add-flux-secrets"

# Bug fix with custom message
git checkout -b fix/yaml-output
# ... make changes ...
task --taskfile taskfiles/git.yaml commit
# Select: "CUSTOM MESSAGE"
# Enter: "fix(kcl): correct YAML formatting in flux module"
```

</details>

<details><summary><b>🔀 pr - Create and Merge Pull Request</b></summary>

Automate pull request creation, checks, and merge into main.

```bash
task --taskfile taskfiles/git.yaml pr
```

**Features:**
- Commits changes first (runs `commit` task)
- Creates PR via GitHub CLI
- Auto-merge with rebase strategy
- Auto-delete source branch after merge
- Switches back to main and pulls latest

**Workflow:**
1. **Commit:** Runs commit task
2. **Create PR:** `gh pr create -t "<branch>" -b "<branch> branch into main"`
3. **Wait:** 2s delay for PR creation
4. **Auto-merge:** Enables auto-merge with rebase
5. **Cleanup:** Deletes branch after merge
6. **Switch to main:** Checks out main and pulls latest

**Requirements:**
- GitHub CLI (`gh`) installed and authenticated
- Branch protection rules configured (optional)
- CI checks configured for auto-merge

**Example:**
```bash
git checkout -b feat/new-taskfile
# ... make changes ...
task --taskfile taskfiles/git.yaml pr
# Creates PR, waits for checks, auto-merges, switches to main
```

</details>

<details><summary><b>🌿 branch - Create New Branch from Main</b></summary>

Create and push a new branch from main with proper tracking.

```bash
task --taskfile taskfiles/git.yaml branch
```

**Workflow:**
1. Switches to main
2. Shows current branches
3. Pulls latest from main
4. Prompts for new branch name
5. Creates local branch
6. Pushes to remote
7. Sets upstream tracking to origin/main

**Example:**
```bash
task --taskfile taskfiles/git.yaml branch
# Enter: "feat/add-dagger-docs"
# Creates and pushes feat/add-dagger-docs
```

</details>

<details><summary><b>🎯 do - Select Task Interactively</b></summary>

Interactive task selector using gum.

```bash
task --taskfile taskfiles/git.yaml do
# Shows menu of all available tasks
```

</details>

<details><summary><b>🧹 run-pre-commit-hook - Domain Sanitization</b></summary>

Replace sensitive domain names in YAML/Markdown files (e.g., `.sva.de` → `.example.com`).

```bash
task --taskfile taskfiles/git.yaml run-pre-commit-hook
```

**What it does:**
- Finds all `.yaml`, `.yml`, `.md` files (excludes Taskfile.yaml)
- Replaces `.sva.de` with `.example.com`
- Stages modified files
- Useful for sanitizing repos before public release

</details>

<details><summary><b>✅ check - Run Pre-commit Hooks</b></summary>

Execute all configured pre-commit hooks.

```bash
task --taskfile taskfiles/git.yaml check
```

**Runs:** `pre-commit run -a`

**Common checks:**
- YAML validation
- Markdown linting
- Trailing whitespace
- File size limits
- Secret detection

</details>

### Workflow Example

<details><summary><b>🔄 Complete Feature Development Flow</b></summary>

```bash
# 1. Create feature branch
task --taskfile taskfiles/git.yaml branch
# Enter: "feat/add-k3s-docs"

# 2. Make changes
vim taskfiles/k3s.yaml

# 3. Commit with conventional commit
task --taskfile taskfiles/git.yaml commit
# Review changes → Confirm → Select "feat: feat/add-k3s-docs"

# 4. Create PR and auto-merge
task --taskfile taskfiles/git.yaml pr
# Auto-creates PR, waits for CI, merges, returns to main

# 5. Start next feature
task --taskfile taskfiles/git.yaml branch
```

</details>

---

## K3s Taskfile

Interactive taskfile for installing and managing K3s clusters with Cilium CNI.

### Overview

**Location**: `taskfiles/k3s.yaml`
**Purpose**: Automated K3s installation without kube-proxy, with Cilium as CNI

### Available Tasks

<details><summary><b>🚀 install - Install K3s Cluster</b></summary>

Install K3s with kube-proxy disabled, ready for Cilium CNI.

```bash
task --taskfile taskfiles/k3s.yaml install
```

**Features:**
- Customizable K3s version
- No kube-proxy (Cilium replacement)
- No default CNI (Flannel disabled)
- Network policy disabled (Cilium handles it)
- Cluster-init mode (HA-ready)
- ServiceLB and Traefik disabled
- Automatic kubeconfig setup

**Workflow:**
1. **K3s Version:** Select version (default: `v1.34.1+k3s1`)
2. **Config Location:** Where to save K3s config (default: `/tmp/k3s-config.yaml`)
3. **Cluster Name:** Cluster identifier (default: `k3s`)
4. **Review Config:** Shows generated configuration
5. **Confirm:** Proceed with installation
6. **Install:** Downloads and installs K3s
7. **Kubeconfig:** Copies to `~/.kube/<cluster-name>`
8. **Verify:** Shows cluster nodes

**Generated K3s Config:**
```yaml
write-kubeconfig-mode: 0644
flannel-backend: none
disable-kube-proxy: true
disable-network-policy: true
cluster-init: true
disable:
  - servicelb
  - traefik
```

**Example:**
```bash
task --taskfile taskfiles/k3s.yaml install
# K3S VERSION? v1.34.1+k3s1
# Config path? /tmp/k3s-config.yaml
# Cluster name? dev-k3s
# Proceed? Yes
# ✅ Kubeconfig saved to ~/.kube/dev-k3s
```

</details>

<details><summary><b>🛠️ cilium:config - Generate Cilium Values</b></summary>

Generate Helm values for Cilium kube-proxy replacement.

```bash
task --taskfile taskfiles/k3s.yaml cilium:config
```

**Features:**
- Auto-detects API server IP
- Configures kube-proxy replacement
- L2 announcements for LoadBalancer
- External IPs support
- Rate limiting configuration
- Single operator replica (local dev)

**Workflow:**
1. **Output Path:** Where to save config (default: `/tmp/cilium-values.yaml`)
2. **Auto-detect:** Gets API server IP from hostname
3. **Generate:** Creates Helm values file
4. **Display:** Shows configuration

**Generated Cilium Config:**
```yaml
k8sServiceHost: <auto-detected-ip>
k8sServicePort: 6443
kubeProxyReplacement: true

l2announcements:
  enabled: true

externalIPs:
  enabled: true

k8sClientRateLimit:
  qps: 50
  burst: 200

operator:
  replicas: 1
  rollOutPods: true

rollOutCiliumPods: true

ingressController:
  enabled: false
```

</details>

<details><summary><b>🌐 cilium:install - Install Cilium CNI</b></summary>

Install Cilium as kube-proxy replacement using generated config.

```bash
task --taskfile taskfiles/k3s.yaml cilium:install
```

**Dependencies:** Runs `cilium:config` first

**Features:**
- Uses Cilium CLI
- Waits for pods to be ready (60s timeout)
- Status verification
- Error handling

**Workflow:**
1. **Generate Config:** Runs `cilium:config` task
2. **Config Path:** Select Cilium config file (default: `/tmp/cilium-values.yaml`)
3. **Kubeconfig Path:** Select kubeconfig (default: `~/.kube/k3s`)
4. **Install:** Runs `cilium install --values <config>`
5. **Wait:** Monitors Cilium pods until ready
6. **Status:** Shows `cilium status`

**Example:**
```bash
task --taskfile taskfiles/k3s.yaml cilium:install
# Config: /tmp/cilium-values.yaml
# Kubeconfig: ~/.kube/dev-k3s
# Installing Cilium...
# Waiting for Cilium pods...
# ✅ Cilium pods are running
# Status: Healthy
```

</details>

<details><summary><b>🗑️ uninstall - Uninstall K3s</b></summary>

Completely remove K3s and all data.

```bash
task --taskfile taskfiles/k3s.yaml uninstall
```

**Warning:** This is destructive! Confirms before execution.

**What it does:**
- Checks if K3s is installed
- Confirms deletion
- Runs `/usr/local/bin/k3s-uninstall.sh`
- Removes all cluster data

</details>

### Complete Setup Example

<details><summary><b>🎯 Full K3s + Cilium Installation</b></summary>

```bash
# 1. Install K3s (no kube-proxy, no CNI)
task --taskfile taskfiles/k3s.yaml install
# Version: v1.34.1+k3s1
# Cluster: dev-k3s

# 2. Generate Cilium config
task --taskfile taskfiles/k3s.yaml cilium:config
# Output: /tmp/cilium-values.yaml

# 3. Install Cilium
task --taskfile taskfiles/k3s.yaml cilium:install
# Config: /tmp/cilium-values.yaml
# Kubeconfig: ~/.kube/dev-k3s

# 4. Verify installation
export KUBECONFIG=~/.kube/dev-k3s
kubectl get nodes
kubectl get pods -n kube-system
cilium status

# 5. Test connectivity
kubectl run test --image=nginx
kubectl expose pod test --port=80
kubectl get svc test
```

**Result:** K3s cluster with Cilium CNI, ready for workloads!

</details>

### Use Cases

<details><summary><b>💡 When to Use This Taskfile</b></summary>

**✅ Perfect for:**
- Local development clusters
- Testing Cilium features (eBPF, NetworkPolicy, etc.)
- Learning kube-proxy replacement
- Lightweight Kubernetes environments
- CI/CD test clusters

**❌ Not recommended for:**
- Production (use production-grade installers)
- Multi-node HA clusters (though cluster-init is enabled)
- Environments requiring default K3s networking

</details>

---

## Tekton Runs Taskfile

Interactive taskfile for creating and managing Tekton PipelineRuns with Ansible and Buildah pipelines.

### Overview

**Location**: `taskfiles/tekton-runs.yaml`
**Purpose**: Generate and execute Tekton pipelines for Ansible automation and container builds

**OCI Packages:**
- `oci://ghcr.io/stuttgart-things/kcl-tekton-pr:0.2.1` (Ansible)
- `oci://ghcr.io/stuttgart-things/kcl-tekton-buildah` (Buildah)

### Available Tasks

<details><summary><b>🤖 create:ansible:pipelinerun - Run Ansible Playbooks</b></summary>

Create and execute Tekton PipelineRun for Ansible playbook automation.

```bash
task --taskfile taskfiles/tekton-runs.yaml create:ansible:pipelinerun
```

**Features:**
- Interactive kubeconfig selection
- StorageClass selection for PVC
- Multi-select Ansible playbooks
- Multi-select Ansible collections
- Interactive inventory builder
- Customizable Ansible working image
- Pipeline prefix customization
- Automatic PipelineRun creation
- Live log streaming with `tkn`

**Workflow:**
1. **Select Kubeconfig:** Choose from `~/.kube/` directory
2. **Verify Cluster:** Shows nodes
3. **Select StorageClass:** Choose SC for workspace PVC
4. **Select Namespace:** Target namespace for PipelineRun
5. **Select Ansible Image:** Default: `ghcr.io/stuttgart-things/sthings-ansible:11.0.0`
6. **Pipeline Prefix:** Default: `pr-ansible`
7. **Select Playbooks:** Multi-select from:
   - `sthings.baseos.prepare_env`
   - `sthings.baseos.setup`
   - `sthings.apps.deploy`
8. **Select Collections:** Multi-select from:
   - `community.crypto`, `community.general`, `ansible.posix`
   - `kubernetes.core`, `community.docker`, `community.vmware`
   - `awx.awx`, `community.hashi_vault`
   - `sthings-container`, `sthings-baseos`, `sthings-awx`, `sthings-rke`
9. **Build Inventory:** Interactive inventory builder
   - Add groups (e.g., `webservers`, `databases`)
   - Add hosts per group
   - Auto-encodes to base64
10. **Generate Manifest:** KCL renders PipelineRun YAML
11. **Apply to Cluster:** Creates PipelineRun
12. **Stream Logs:** Follows logs with `tkn pr logs -f`

**Pre-defined Collections:**
```
community.crypto:2.22.3
community.general:10.1.0
ansible.posix:2.0.0
kubernetes.core:5.0.0
community.docker:4.1.0
community.vmware:5.2.0
awx.awx:24.6.1
community.hashi_vault:6.2.0
sthings-container-25.0.286
sthings-baseos-25.6.990
sthings-awx-25.4.506
sthings-rke-25.6.394
```

**Example Inventory Builder:**
```
Enter inventory group name: webservers
Enter host for group 'webservers': web1.example.com
Enter host for group 'webservers': web2.example.com
Enter host for group 'webservers': <leave empty>

Enter inventory group name: databases
Enter host for group 'databases': db1.example.com
Enter host for group 'databases': <leave empty>

Enter inventory group name: <leave empty to finish>
```

**Generated Inventory:**
```ini
[webservers]
web1.example.com
web2.example.com

[databases]
db1.example.com
```

**Output:**
```bash
Generating Tekton PipelineRun manifest with KCL...
KCL output saved to /tmp/pipelinerun.yaml
Applying PipelineRun to cluster...
pipelinerun.tekton.dev/pr-ansible-20250122 created
Most recent PipelineRun: pr-ansible-20250122
Fetching logs for pr-ansible-20250122...
[install-collections : install-collections] Installing collections...
[run-playbooks : run-playbooks] Running playbook: sthings.baseos.setup...
```

</details>

<details><summary><b>🐳 create:buildah:pipelinerun - Build Container Images</b></summary>

Create Tekton PipelineRun for building container images with Buildah.

```bash
task --taskfile taskfiles/tekton-runs.yaml create:buildah:pipelinerun
```

**Features:**
- Interactive kubeconfig selection
- StorageClass selection for build cache
- KCL-based manifest generation
- Uses `kcl-tekton-buildah` module

**Workflow:**
1. **Select Kubeconfig:** Choose from `~/.kube/`
2. **Verify Cluster:** Shows nodes
3. **Select StorageClass:** Choose SC for build workspace
4. **Generate Manifest:** KCL renders PipelineRun
5. **Save to File:** `/tmp/buildah-pr.yaml`

**Configuration Options (in KCL):**
- `gitUrl` - Git repository URL
- `branchName` - Git branch (default: `main`)
- `context` - Build context path
- `verifySsl` - SSL verification (default: `true`)

**Example:**
```bash
task --taskfile taskfiles/tekton-runs.yaml create:buildah:pipelinerun
# Kubeconfig: ~/.kube/dev-k3s
# StorageClass: local-path
# Generated: /tmp/buildah-pr.yaml

# Apply manually
kubectl apply -f /tmp/buildah-pr.yaml -n tekton-ci
```

**Note:** Currently generates manifest only (commented out auto-apply)

</details>

<details><summary><b>🔧 build:ansible:inventory - Build Ansible Inventory</b></summary>

Standalone inventory builder (used by `create:ansible:pipelinerun`).

```bash
task --taskfile taskfiles/tekton-runs.yaml build:ansible:inventory
```

**Output:** Base64-encoded inventory string

**Example:**
```bash
INVENTORY=$(task --taskfile taskfiles/tekton-runs.yaml build:ansible:inventory)
echo $INVENTORY | base64 -d
```

</details>

<details><summary><b>🎯 kube - Select Kubeconfig</b></summary>

Interactive kubeconfig selector with export command.

```bash
task --taskfile taskfiles/tekton-runs.yaml kube
```

**Workflow:**
1. Lists all files in `~/.kube/`
2. Select kubeconfig
3. Shows nodes
4. Prints export command

**Output:**
```bash
SWITCHING TO dev-k3s
NAME      STATUS   ROLES                  AGE   VERSION
dev-k3s   Ready    control-plane,master   5m    v1.34.1+k3s1

export KUBECONFIG=/home/user/.kube/dev-k3s
```

**Usage:**
```bash
eval $(task --taskfile taskfiles/tekton-runs.yaml kube | grep '^export')
kubectl get pods
```

</details>

<details><summary><b>📋 do - Select Task Interactively</b></summary>

Interactive task menu using gum.

```bash
task --taskfile taskfiles/tekton-runs.yaml do
```

</details>

<details><summary><b>🔢 pr:select:list - Multi-select from List</b></summary>

Helper task for multi-selecting items from comma-separated list.

```bash
task --taskfile taskfiles/tekton-runs.yaml pr:select:list listitems="item1,item2,item3"
```

**Output:** JSON array format `["item1", "item2"]`

</details>

### Complete Ansible Pipeline Example

<details><summary><b>🎯 Full Ansible Playbook Execution</b></summary>

**Scenario:** Configure web servers with base OS setup and deploy applications

```bash
# 1. Run the Ansible pipeline task
task --taskfile taskfiles/tekton-runs.yaml create:ansible:pipelinerun

# Interactive prompts:
# ├─ Kubeconfig: dev-k3s
# ├─ StorageClass: local-path
# ├─ Namespace: tekton-ci
# ├─ Ansible Image: ghcr.io/stuttgart-things/sthings-ansible:11.0.0
# ├─ Pipeline Prefix: pr-ansible
# ├─ Playbooks:
# │  ├─ ✓ sthings.baseos.prepare_env
# │  ├─ ✓ sthings.baseos.setup
# │  └─ ✓ sthings.apps.deploy
# ├─ Collections:
# │  ├─ ✓ community.general:10.1.0
# │  ├─ ✓ ansible.posix:2.0.0
# │  └─ ✓ sthings-baseos-25.6.990
# └─ Inventory Builder:
#    ├─ Group: webservers
#    │  ├─ web1.example.com
#    │  └─ web2.example.com
#    └─ Group: databases
#       └─ db1.example.com

# 2. Watch pipeline execution
# (automatically starts streaming logs)

# 3. Verify results
kubectl get pipelineruns -n tekton-ci
tkn pr describe pr-ansible-20250122 -n tekton-ci
```

**Generated PipelineRun:**
```yaml
apiVersion: tekton.dev/v1
kind: PipelineRun
metadata:
  name: pr-ansible-20250122
  namespace: tekton-ci
spec:
  pipelineRef:
    name: ansible-playbook-pipeline
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: [ReadWriteOnce]
          resources:
            requests:
              storage: 1Gi
  params:
    - name: ansible-image
      value: ghcr.io/stuttgart-things/sthings-ansible:11.0.0
    - name: playbooks
      value: ["sthings.baseos.prepare_env", "sthings.baseos.setup", "sthings.apps.deploy"]
    - name: collections
      value: ["community.general:10.1.0", "ansible.posix:2.0.0", "sthings-baseos-25.6.990"]
    - name: inventory
      value: "W3dlYnNlcnZlcnNdCndlYjEuZXhhbXBsZS5jb20Kd2ViMi5leGFtcGxlLmNvbQoKW2RhdGFiYXNlc10KZGIXMS5leGFtcGxlLmNvbQo="
```

</details>

### Use Cases

<details><summary><b>💡 Common Scenarios</b></summary>

**1. Infrastructure Provisioning:**
```bash
# Playbooks: sthings.baseos.prepare_env, sthings.baseos.setup
# Inventory: Multiple server groups
# Collections: community.general, ansible.posix
```

**2. Application Deployment:**
```bash
# Playbooks: sthings.apps.deploy
# Inventory: Application servers
# Collections: kubernetes.core, community.docker
```

**3. AWX Configuration:**
```bash
# Playbooks: sthings.awx.*
# Collections: awx.awx, community.hashi_vault
```

**4. VMware Automation:**
```bash
# Collections: community.vmware
# Playbooks: VM provisioning/configuration
```

**5. Container Image Builds:**
```bash
# Use: create:buildah:pipelinerun
# Purpose: CI/CD container builds with Tekton
```

</details>

### Requirements

<details><summary><b>📋 Prerequisites</b></summary>

**Cluster Requirements:**
- Tekton Pipelines installed
- StorageClass available for PVCs
- Namespace for PipelineRuns (e.g., `tekton-ci`)

**CLI Tools:**
- `kubectl` - Kubernetes CLI
- `tkn` - Tekton CLI
- `gum` - Interactive prompts
- `kcl` - KCL CLI

**Install Tekton CLI:**
```bash
brew install tektoncd-cli

# Or download binary
curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
tar xzf tkn_Linux_x86_64.tar.gz
sudo mv tkn /usr/local/bin/
```

**Tekton Pipelines:**
Assumes pipelines are pre-installed in cluster:
- `ansible-playbook-pipeline`
- `buildah-build-pipeline`

</details>

---

## Tips & Best Practices
