# Environment Variables for Flux Taskfile

The Flux taskfile supports reading secrets from environment variables, making it ideal for automation and CI/CD pipelines.

## Supported Environment Variables

| Variable | Purpose | Used For |
|----------|---------|----------|
| `GITHUB_USER` | Git username | Default for Git authentication username |
| `GITHUB_TOKEN` | Git personal access token | Auto-fills Git password/token (no prompt) |
| `SOPS_AGE_KEY` | SOPS AGE private key | Auto-fills SOPS decryption key (no prompt) |

## Usage

### Interactive with Environment Variables

The taskfile will automatically detect and use environment variables:

```bash
# Set environment variables
export GITHUB_USER="patrick-hermann-sva"
export GITHUB_TOKEN="ghp_..."
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."

# Run interactive taskfile
task --taskfile taskfiles/flux.yaml render
```

**What happens:**
1. ✓ Shows checkmarks for detected environment variables
2. ✓ Uses `GITHUB_USER` as default for username prompt
3. ✓ Automatically uses `GITHUB_TOKEN` (no password prompt)
4. ✓ Automatically uses `SOPS_AGE_KEY` (no key prompt)

### Fully Automated (No Prompts)

For automation scenarios, you can combine environment variables with non-interactive mode:

```bash
# Set environment variables
export GITHUB_USER="automation-bot"
export GITHUB_TOKEN="ghp_AutomationToken123"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1..."

# All prompts can be pre-answered or automated
# (Note: This example shows the concept - full automation would require additional scripting)
```

### CI/CD Pipeline Example

**GitHub Actions:**

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
          # Install Task, gum, kcl, kubectl
          curl -sL https://taskfile.dev/install.sh | sh
          # ... other installations
      
      - name: Deploy Flux
        run: |
          task --taskfile taskfiles/flux.yaml render
          # Interactive prompts will use environment variables
```

**GitLab CI:**

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

## Security Best Practices

### 1. Never Commit Secrets

```bash
# ❌ DON'T DO THIS
export GITHUB_TOKEN="ghp_RealTokenHere123"
git add .env

# ✅ DO THIS
# Add to .gitignore
echo ".env" >> .gitignore
echo "*.secret" >> .gitignore
```

### 2. Use Secret Management

```bash
# Load from secure vault
export GITHUB_TOKEN=$(vault kv get -field=token secret/flux/github)
export SOPS_AGE_KEY=$(vault kv get -field=key secret/flux/sops)

# Or from encrypted file
export GITHUB_TOKEN=$(sops -d secrets.yaml | yq e '.github.token' -)
export SOPS_AGE_KEY=$(sops -d secrets.yaml | yq e '.sops.key' -)
```

### 3. Temporary Secrets

```bash
# Set secrets only for current command (not persisted in shell history)
GITHUB_TOKEN="ghp_..." SOPS_AGE_KEY="AGE-..." task --taskfile taskfiles/flux.yaml render
```

### 4. File-based Secrets

```bash
# Read from secure files
export GITHUB_TOKEN=$(cat ~/.secrets/github-token)
export SOPS_AGE_KEY=$(cat ~/.secrets/sops-age-key)

# Ensure secure file permissions
chmod 600 ~/.secrets/*
```

## Examples

### Development Workflow

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

# Run taskfile (auto-uses environment variables)
task --taskfile taskfiles/flux.yaml render
```

### Production Deployment

```bash
# Load from production vault
eval $(vault kv get -format=json secret/prod/flux | jq -r '
  .data.data | 
  "export GITHUB_USER=\(.github_user)\n" +
  "export GITHUB_TOKEN=\(.github_token)\n" +
  "export SOPS_AGE_KEY=\(.sops_age_key)"
')

# Deploy with secrets from vault
task --taskfile taskfiles/flux.yaml render
```

### Multi-Environment Setup

```bash
# ~/.secrets/flux-dev.env
export GITHUB_USER="dev-bot"
export GITHUB_TOKEN="ghp_DevToken"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1DEV..."

# ~/.secrets/flux-prod.env
export GITHUB_USER="prod-bot"
export GITHUB_TOKEN="ghp_ProdToken"
export SOPS_AGE_KEY="AGE-SECRET-KEY-1PROD..."

# Use based on environment
source ~/.secrets/flux-${ENVIRONMENT}.env
task --taskfile taskfiles/flux.yaml render
```

## Verification

Check which environment variables are set:

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

## Taskfile Behavior

### With Environment Variables Set

```
🚀 FluxInstance Configuration
================================

╔══════════════════════╗
║  Kubernetes Secrets  ║
╚══════════════════════╝

✓ Found GITHUB_USER environment variable
✓ Found GITHUB_TOKEN environment variable
✓ Found SOPS_AGE_KEY environment variable

Render Kubernetes Secrets? [Choose: false, true]
> true

📝 Git Authentication Secret
Git secret name? git-token-auth
Git username? patrick-hermann-sva  ← Auto-filled from $GITHUB_USER
Using GITHUB_TOKEN from environment  ← No password prompt!

🔐 SOPS Decryption Secret
SOPS secret name? sops-age
Using SOPS_AGE_KEY from environment  ← No key prompt!
```

### Without Environment Variables

```
🚀 FluxInstance Configuration
================================

╔══════════════════════╗
║  Kubernetes Secrets  ║
╚══════════════════════╝

Render Kubernetes Secrets? [Choose: false, true]
> true

📝 Git Authentication Secret
Git secret name? git-token-auth
Git username? github-user  ← Manual input required
Git password/token? ******  ← Manual input required

🔐 SOPS Decryption Secret
SOPS secret name? sops-age
SOPS AGE private key? ******  ← Manual input required
```

## Troubleshooting

### Variables Not Being Used

```bash
# Ensure variables are exported (not just set)
export GITHUB_TOKEN="..."  # ✅ Correct
GITHUB_TOKEN="..."         # ❌ Won't work (not exported)

# Check if exported
env | grep GITHUB_TOKEN    # Should show the variable
```

### Variables from Files Not Working

```bash
# Make sure to source the file (not execute it)
source ~/.secrets/flux-env  # ✅ Correct
bash ~/.secrets/flux-env    # ❌ Won't work (runs in subshell)
. ~/.secrets/flux-env       # ✅ Also correct (shorthand for source)
```

### Token in Shell History

```bash
# Check history for exposed tokens
history | grep -i token

# Clear history if needed
history -c

# Use space prefix to avoid history (in bash)
 export GITHUB_TOKEN="..."  # Note the leading space
```

## See Also

- [FLUX-README.md](FLUX-README.md) - Main taskfile documentation
- [Flux Secrets Documentation](../../kcl/kcl-flux-instance/SECRETS.md) - Secret rendering details
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [SOPS AGE Encryption](https://github.com/FiloSottile/age)
