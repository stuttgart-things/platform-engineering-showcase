# TASKFILES

## REQUIREMENTS

<details><summary>INSTALL BREW</summary>

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

</details>

<details><summary>INSTALL TASK</summary>

### INSTALL TASK

```bash
brew install go-task/tap/go-task gum
```

</details>

<details><summary>K3s</summary>

### INSTALL CILIUM-CLI + K8S BINS

```bash
brew install cilium-cli k9s kubectl helm helmfile
```





</details>
