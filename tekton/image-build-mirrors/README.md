# Platform Engineering Showcase - Image Build Mirrors

This project provides tools for managing container images, packages, and Helm charts in air-gapped environments. It supports both export operations (from internet-facing environments) and import operations (for air-gapped environments).

## 🚀 Quick Start

### Interactive Mode (Recommended)

The easiest way to use this project is through the interactive Taskfile menu:

```bash
# Start interactive menu
task

# Or explicitly
task menu
```

This provides a user-friendly interface with gum for all operations without needing to remember complex script parameters.

### Direct Script Usage

You can also use the underlying scripts directly for automation or scripting purposes.

## 📋 Prerequisites

<details><summary>📦 Installation Requirements</summary>

### Required Tools

- [Task](https://taskfile.dev/installation/) - Task runner for interactive menus
- [gum](https://github.com/charmbracelet/gum) - Interactive CLI tool
- Container runtime (Docker or Podman)
- Helm (for chart operations)

### Install gum

```bash
# Ubuntu/Debian
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum

# macOS
brew install gum

# Go install
go install github.com/charmbracelet/gum@latest
```

### Install Task

```bash
# Ubuntu/Debian
sudo apt install task

# macOS
brew install go-task

# Go install
go install github.com/go-task/task/v3/cmd/task@latest
```

</details>

## 🎯 Interactive Usage

### Main Menu Navigation

```bash
task menu
```

**Available Categories:**
- **Export (Internet-facing)** - Download and package resources
- **Import (Air-gapped)** - Install packages in offline environments
- **Analyze** - Discover images and dependencies
- **Exit** - Quit the application

### Quick Task Commands

```bash
# Export operations
task export                    # Interactive export menu
task export:container-images   # Export container images
task export:apk-packages      # Export APK packages
task export:pip-packages      # Export PIP packages
task export:helm-chart        # Download Helm charts

# Import operations
task import                    # Interactive import menu
task import:container-images   # Import container images
task import:packages          # Import APK/PIP packages

# Analysis operations
task analyze                   # Interactive analysis menu
task analyze:project          # Analyze project directory
task analyze:namespace        # Analyze K8s namespace
task analyze:helm-chart       # Analyze Helm chart

# Help
task help                     # Show all available tasks
```

## 📤 Export Operations (Internet-Facing)

These operations are designed to run in environments with internet access to download and package resources for offline use.

<details><summary>🐳 Export Container Images</summary>

**Interactive:**
```bash
task export:container-images
```

**Direct Script:**
```bash
sh scripts/export-container-images.sh \
  --images "python:3.13.7-alpine,redis" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name python_redis_images
```

**Parameters:**
- `--images`: Comma-separated list of container images
- `--runtime`: Container runtime (docker/podman)
- `--output-dir`: Directory to save the tar archive
- `--archive-name`: Name for the output archive

</details>

<details><summary>📦 Export APK Packages</summary>

**Interactive:**
```bash
task export:apk-packages
```

**Direct Script:**
```bash
sh scripts/export-apk-packages.sh \
  --image "alpine:3.20" \
  --apk-packages "bash,curl,git" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name alpine20_apks
```

**Parameters:**
- `--image`: Base Alpine image to use
- `--apk-packages`: Comma-separated list of APK packages
- `--runtime`: Container runtime (docker/podman)
- `--output-dir`: Directory to save the package bundle
- `--archive-name`: Name for the output archive

</details>

<details><summary>🐍 Export PIP Packages</summary>

**Interactive:**
```bash
task export:pip-packages
```

**Direct Script:**
```bash
sh scripts/export-pip-packages.sh \
  --image python:3.13.7-alpine \
  --pip-packages "flask,requests,sqlalchemy" \
  --runtime docker \
  --output-dir /tmp \
  --archive-name flask_bundle
```

**Parameters:**
- `--image`: Base Python image to use
- `--pip-packages`: Comma-separated list of PIP packages
- `--runtime`: Container runtime (docker/podman)
- `--output-dir`: Directory to save the package bundle
- `--archive-name`: Name for the output archive

</details>

<details><summary>⎈ Download Helm Charts</summary>

**Interactive:**
```bash
task export:helm-chart
```

**Direct Commands:**

**Option 1: Chart Repository**
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm pull kyverno/kyverno --version 3.5.1
```

**Option 2: OCI Repository**
```bash
helm pull oci://ghcr.io/stuttgart-things/tekton/tekton --version 0.77.0
```

</details>

## 📥 Import Operations (Air-Gapped)

These operations are designed for air-gapped environments to install previously exported resources.

<details><summary>🐳 Import Container Images</summary>

**Interactive:**
```bash
task import:container-images
```

**Direct Script:**
```bash
sh scripts/import-container-images.sh \
  --runtime docker \
  --input-dir /tmp \
  --archive-name python_redis_images
```

**Parameters:**
- `--runtime`: Container runtime (docker/podman)
- `--input-dir`: Directory containing the tar archive
- `--archive-name`: Name of the archive to import

</details>

<details><summary>📦 Import Packages (APK or PIP)</summary>

**Interactive:**
```bash
task import:packages
```

**Direct Script:**
```bash
sh scripts/import-packages.sh \
  --zip-path /tmp/pip-flask_bundle.zip \
  --pvc-path /mnt/pvc \
  --force
```

**Parameters:**
- `--zip-path`: Path to the package bundle ZIP file
- `--pvc-path`: Mount path for persistent volume
- `--force`: Force overwrite existing files (optional)

</details>

<details><summary>🚀 Push Container Images to Registry</summary>

**Direct Script:**
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

**Parameters:**
- `--tar-file`: Path to the container image tar file
- `--target-registry`: Target container registry URL
- `--namespace`: Kubernetes namespace
- `--target-image`: Target image name and tag
- `--username`: Registry username
- `--password`: Registry password
- `--pod-name`: Temporary pod name for skopeo
- `--image`: Skopeo image to use

</details>

## 🔍 Analysis Operations

These operations help discover images and dependencies in existing projects, clusters, and charts.

<details><summary>📁 Analyze Project Directory</summary>

**Interactive:**
```bash
task analyze:project
```

**Direct Script:**
```bash
sh scripts/analyze-project-dir.sh --dir _example
```

Scans a project directory for container image references in various file types (Dockerfile, docker-compose.yml, Kubernetes manifests, etc.).

</details>

<details><summary>☸️ Analyze Kubernetes Namespace</summary>

**Interactive:**
```bash
task analyze:namespace
```

**Direct Script:**
```bash
sh scripts/analyze-images-namespace.sh --namespace tekton-operator
```

Discovers all container images currently running in a specified Kubernetes namespace.

</details>

<details><summary>⎈ Analyze Helm Chart</summary>

**Interactive:**
```bash
task analyze:helm-chart
```

**Direct Script:**
```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
sh scripts/analyze-helm-chart.sh \
  --name kyverno \
  --charturl kyverno/kyverno \
  --version 3.5.1
```

Extracts all container image references from a Helm chart.

</details>

## 🏗️ Environment Setup

<details><summary>🔧 Create Test Cluster</summary>

### Option 1: KIND

```bash
# Create KIND cluster
kind create cluster --name airgap-test

# Set context
kubectl cluster-info --context kind-airgap-test
```

### Option 2: vcluster

```bash
# Install vcluster CLI
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64"
sudo install -c -m 0755 vcluster /usr/local/bin

# Create vcluster
vcluster create airgap-test --namespace vcluster-airgap

# Connect to vcluster
vcluster connect airgap-test --namespace vcluster-airgap
```

</details>

<details><summary>🪞 Deploy APK+PIP Mirror</summary>

Deploy package mirrors for offline package installation:

```bash
# Deploy APK mirror
kubectl apply -f manifests/apk-mirror.yaml

# Deploy PIP mirror
kubectl apply -f manifests/pip-mirror.yaml

# Configure mirror endpoints
kubectl create configmap package-mirrors \
  --from-literal=apk-mirror=http://apk-mirror.default.svc.cluster.local \
  --from-literal=pip-mirror=http://pip-mirror.default.svc.cluster.local
```

</details>

<details><summary>🔄 Deploy Tekton</summary>

Install Tekton Pipelines for CI/CD in air-gapped environments:

```bash
# Download Tekton manifests (internet-facing environment)
curl -LO https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Apply in air-gapped environment
kubectl apply -f release.yaml

# Verify installation
kubectl get pods -n tekton-pipelines
```

</details>

## 📊 Example Workflows

<details><summary>🔄 Complete Export-Import Workflow</summary>

### Export Phase (Internet-facing)

```bash
# 1. Analyze existing project
task analyze:project
# Input: ./my-project

# 2. Export discovered images
task export:container-images
# Input: nginx:1.21,postgres:13,redis:alpine

# 3. Export Python dependencies
task export:pip-packages
# Input: python:3.9-slim, "django,psycopg2,celery"

# 4. Export Helm charts
task export:helm-chart
# Input: Chart repo, nginx-ingress, 4.1.0
```

### Import Phase (Air-gapped)

```bash
# 1. Import container images
task import:container-images
# Input: /mnt/usb/container_images

# 2. Import Python packages
task import:packages
# Input: /mnt/usb/pip-django_bundle.zip, /opt/pip-mirror

# 3. Deploy applications using imported resources
kubectl apply -f my-project/manifests/
```

</details>

<details><summary>📈 Kubernetes Migration Workflow</summary>

### Source Cluster Analysis

```bash
# Analyze all namespaces
for ns in $(kubectl get ns -o name | cut -d/ -f2); do
  task analyze:namespace
  # Input: $ns
done

# Export all discovered images
task export:container-images
# Input: <discovered_images_list>
```

### Target Cluster Setup

```bash
# Import images to air-gapped cluster
task import:container-images

# Push to internal registry
sh scripts/push-tar-image.sh \
  --tar-file ./cluster_images.tar \
  --target-registry internal-registry.local \
  --namespace default
```

</details>

## 🎨 Interactive Features

### gum Integration Benefits

- **🎯 User-friendly**: No need to remember complex script parameters
- **⚡ Fast**: Quick navigation through interactive menus
- **🔒 Safe**: Interactive confirmation for destructive operations
- **📋 Consistent**: Standardized parameter collection across all operations
- **🎨 Beautiful**: Rich terminal UI with gum styling
- **🚀 Productive**: Reduces command-line complexity

### Parameter Input Features

- **Smart Defaults**: Pre-filled common values
- **Input Validation**: Real-time parameter checking
- **Choice Menus**: Select from predefined options
- **Confirmation Dialogs**: Prevent accidental operations
- **Help Integration**: Context-sensitive help

## 📁 Project Structure

```
.
├── README.md                          # This file
├── Taskfile.yaml                      # Interactive task definitions
├── scripts/                           # Shell scripts for all operations
│   ├── analyze-helm-chart.sh         # Analyze Helm charts
│   ├── analyze-images-namespace.sh   # Analyze K8s namespace images
│   ├── analyze-project-dir.sh        # Analyze project directory
│   ├── export-apk-packages.sh        # Export APK packages
│   ├── export-container-images.sh    # Export container images
│   ├── export-pip-packages.sh        # Export PIP packages
│   ├── import-container-images.sh    # Import container images
│   ├── import-container-registry.sh  # Import to registry
│   └── import-packages.sh            # Import APK/PIP packages
├── manifests/                         # Kubernetes manifests
│   ├── apk-mirror.yaml               # APK package mirror
│   └── pip-mirror.yaml               # PIP package mirror
└── examples/                          # Example configurations
    ├── project-structure/             # Sample project layouts
    └── workflows/                     # Example workflow definitions
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add new scripts or improve existing ones
4. Update the Taskfile.yaml for interactive support
5. Test with both interactive and direct modes
6. Submit a pull request

## 📝 License

This project is part of the Stuttgart-Things Platform Engineering Showcase.

## 🔗 Related Projects

- [Stuttgart-Things](https://github.com/stuttgart-things) - Platform engineering resources
- [Tekton](https://tekton.dev/) - Cloud native CI/CD
- [gum](https://github.com/charmbracelet/gum) - Interactive CLI tool
- [Task](https://taskfile.dev/) - Task runner
