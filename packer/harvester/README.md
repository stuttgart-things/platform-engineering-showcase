# PACKER QEMU

## Prerequisites

| Package | Purpose |
|---------|---------|
| QEMU | VM emulation |
| KVM | Hardware acceleration |
| Packer | Image build tool |
| Ansible | Provisioning |

<details><summary>Quick Install (Debian/Ubuntu)</summary>

```bash
sudo apt install -y qemu-system-x86 qemu-utils qemu-kvm ansible cpu-checker
```

</details>

<details><summary>Verify KVM Access</summary>

```bash
# Check KVM is available
kvm-ok

# Your user needs to be in the kvm group
sudo usermod -aG kvm $USER
# Then log out and back in
```

</details>

<details><summary>Install Brew</summary>

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

</details>

<details><summary>Install Packer (via Brew)</summary>

```bash
brew install gcc
brew tap hashicorp/tap
brew install llvm
brew install packer
```

</details>

## Build

```bash
cd u25
packer init .
packer build ubuntu-plucky.pkr.hcl
```

Output: `output/ubuntu-plucky/ubuntu-plucky.qcow2`

## Commands

```bash
# Get checksum of ISO
curl -s https://releases.ubuntu.com/25.04/SHA256SUMS | grep live-server
```
