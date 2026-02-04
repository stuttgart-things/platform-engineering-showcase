# Ubuntu Image Build & Harvester Upload (Packer/QEMU)

This directory provides a Packer/QEMU setup to build a custom Ubuntu cloud image with user and package configuration via YAML, and optionally upload it directly to Harvester.

## Key Components

- **spec.pkr.hcl**: QEMU image build definition, including cloud-init, SSH, KVM, EFI, and upload post-processor.
  ```hcl
  source "qemu" "ubuntu_cloud" {
    iso_url      = var.ubuntu_url
    iso_checksum = var.ubuntu_checksum
    cpus         = 2
    memory       = 4096
    accelerator  = "kvm"
    efi_boot     = true
    ssh_username = "ubuntu"
    ssh_password = "superpassword" # pragma: allowlist secret
    ...
  }
  ```
- **spec.cloud-init.pkr.hcl**: Generates cloud-init user-data/meta-data from YAML files.
  ```hcl
  locals {
    users_config    = yamldecode(file(var.users_file))
    packages_config = yamldecode(file(var.packages_file))
  }
  source "file" "user_data" {
    content = format("#cloud-config\n%s", yamlencode({
      ssh_pwauth: true,
      packages: local.packages_config.packages,
      users: ...
    }))
    target = "user-data"
  }
  ```
- **variables.pkr.hcl**: Defines all variables, e.g. image name, YAML paths, Harvester upload.
  ```hcl
  variable "ubuntu_url" { default = "https://cloud-images.ubuntu.com/<version>/current/<image-file>.img" }
  variable "upload_to_harvester" { default = "false" }
  ```
- **users.yaml / packages.yaml**: List users and packages for cloud-init.
  ```yaml
  users:
    - name: pat
      groups: sudo
      ssh_authorized_keys:
        - ssh-ed25519 AAAA...
  packages:
    - qemu-guest-agent
    - vim
    - curl
  ```
- **upload.sh**: Script for authentication and image upload to Harvester via API.
  ```bash
  TOKEN=$(curl -sk -X POST "https://${HARVESTER_VIP}/v3-public/localProviders/local?action=login" ...)
  curl -sk -X POST -F "chunk=@${IMAGE_FILE}" "https://${HARVESTER_VIP}/v1/harvester/harvesterhci.io.virtualmachineimages/${NAMESPACE}/${IMAGE_NAME}?action=upload&size=${IMAGE_SIZE}"
  ```

## Build & Upload

- Build image:
  ```bash
  packer build .
  ```
- Build & upload to Harvester:
  ```bash
  packer build -var 'upload_to_harvester=true' -var 'harvester_vip=10.31.101.8' -var 'harvester_password=yourpassword' .
  ```

## Highlights

- Cloud-init users and packages are easily managed via YAML.
- Upload to Harvester is optional and controlled by a variable.
- Ready for automation (e.g. GitHub Actions, Backstage).

---

## GitHub Actions Workflows

### packer-pr-build.yml

This workflow automatically builds and uploads the Ubuntu image to Harvester when a pull request affecting `harvester/packer/ubuntu25/**` is opened, synchronized, or reopened against the `main` branch. It can also be triggered manually.

**Key steps:**
- Runs on a self-hosted runner with KVM support (`runs-on: kvm`).
- Checks out the repository.
- Shows build parameters (directory, image name, upload flag, PR number, etc.).
- Initializes Packer in the `harvester/packer/ubuntu25` directory:
  ```bash
  packer init .
  ```
- Builds the image and uploads to Harvester using secrets for authentication:
  ```bash
  packer build .
  # with env vars: PKR_VAR_image_name, PKR_VAR_upload_to_harvester, PKR_VAR_harvester_vip, PKR_VAR_harvester_password
  ```
- If the build succeeds and the event is a pull request, the workflow auto-merges the PR using the GitHub CLI:
  ```bash
  gh pr merge <PR_NUMBER> --auto --squash --delete-branch
  ```

### packer-build.yml

This workflow is designed for manual (workflow_dispatch) builds and is highly configurable via input parameters.

**Inputs:**
- `packer_dir`: Directory with Packer config (default: `harvester/packer/ubuntu25`)
- `template`: Packer template (default: `.`)
- `var_file`: Optional Packer var-file
- `image_name`: Name for the VM image (default: `ubuntu-base`)
- `upload_to_harvester`: Whether to upload to Harvester (default: false)
- `packer_log`: Enable debug logging (default: false)

**Key steps:**
- Runs on a KVM-enabled runner.
- Shows all input parameters for traceability.
- Initializes Packer in the specified directory and template:
  ```bash
  packer init <template>
  ```
- Builds the image, optionally using a var-file, and uploads to Harvester if requested:
  ```bash
  packer build -var-file="<var_file>" <template>
  # or just
  packer build <template>
  ```
- Uses GitHub secrets for Harvester credentials.

**Use case:**
- This workflow is ideal for ad-hoc builds, CI/CD integration, or when you want to override variables or use different YAML/user configs.

---

<details>
<summary><strong>Backstage Template: harvester-packer-devimage – Logic Overview</strong></summary>

### 1. Packer Code Generation
- The template uses two skeleton files (`packages.yaml`, `users.yaml`) to generate the configuration for the Packer build.
- Existing users and packages are fetched from the main repository and merged with new entries provided via the Backstage form.
- Jinja-style templating ensures that both existing and new users/packages are included:
  ```yaml
  # packages.yaml
  packages:
    # Existing packages
    - ...
    # New packages
    - ...
  # users.yaml
  users:
    - name: ...
      groups: ...
      shell: ...
      sudo: ...
      ssh_authorized_keys:
        - ...
  ```

### 2. Pipelining Logic
- The template defines a series of steps:
  1. **Fetch Existing Configuration:** Downloads the current `packages.yaml` and `users.yaml` from the main branch.
  2. **Parse YAML:** Parses the existing YAML files to extract lists of users and packages.
  3. **Render New Config:** Combines existing and new entries and renders new YAML files using the skeleton templates.
  4. **Create Pull Request:** Publishes a PR to the main repository with the updated configuration in `harvester/packer/ubuntu25`.
- The PR description summarizes the changes (new users/packages).
- Once the PR is created, the Packer build pipeline is triggered automatically (see GitHub Actions docs above).

### 3. Backstage Integration
- The template is defined as a Backstage Software Template (`apiVersion: scaffolder.backstage.io/v1beta3`).
- Users interact via a form in Backstage, specifying additional users and packages.
- The form supports multiple users/packages, with fields for username, groups, shell, sudo rule, and SSH key.
- After submission, Backstage orchestrates the pipeline, PR creation, and provides a direct link to the resulting PR and next steps.
- The process is fully automated: after PR creation, the build pipeline runs and, on success, the PR is auto-merged.

</details>