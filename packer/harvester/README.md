# PACKER QUEMU

<details><summary>INSTALL BREW </summary>

```bash
# BREW
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

</details>

<details><summary>Install Packer</summary>

```bash
brew install gcc
brew tap hashicorp/tap
brew install llvm
brew install packer
sudo apt install -y qemu-system-x86 qemu-utils
```

</details>

<details><summary>CMDS</summary>

```bash
# GET CHECKSUM OF ISO
curl -s https://releases.ubuntu.com/25.04/SHA256SUMS | grep live-server
```

</details>
