# platform-engineering-showcase/tinkerbell/stack

## DEPLOYMENT STACK/TINKERBELL-SERVER

<details><summary>INSTALL REQUIREMENTS</summary>

### INSTALL REQUIREMENTS

```bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install build-essential procps curl file git -y
```

### INSTALL BREW

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```


### INSTALL TASK

```bash
brew install go-task/tap/go-task gum
brew install kubectl helm k9s
```

</details>
