# TEKTON-BASE

## DEPLOY

<details><summary>INSTALL REQUIREMENTS</summary>

### INSTALL BREW

```bash
NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ${HOME}/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

### INSTALL REQUIREMENTS

```bash
brew install helmfile tektoncd-cli
# if not already installed
brew install kubectl helm k9s
```

### INSTALL TEKTON

```bash
# export KUBECONFIG=~/.kube/tekton - EXAMPLE PATH
kubectl apply -k https://github.com/stuttgart-things/helm/cicd/crds/tekton?ref=v1.2.1
helmfile init --force
helmfile apply -f tekton-base.yaml.gotmpl
kubectl create ns tekton-ci
```

</details>

## PIPELINERUN-REQUIREMENTS

<details><summary>CREATE SECRETS</summary>

## CREATE SSH USER-CREDS AS SECRET

```bash
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: ansible-credentials
  namespace: tekton-ci
type: Opaque
stringData:
  ANSIBLE_USER: ""
  ANSIBLE_PASSWORD: ""
EOF
```

## CREATE SSH USER-CREDS AS SECRET

secret must exist, values doesnt matter if you're not using vault.

```bash
kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: vault
  namespace: tekton-ci
type: Opaque
stringData:
  VAULT_NAMESPACE: root
  VAULT_ROLE_ID: ""
  VAULT_SECRET_ID: ""
  VAULT_ADDR: ""
EOF
```

</details>

## CREATE PIPELINERUNS

<details><summary>INSTALL REQUIREMENTS</summary>

```bash
brew tap kcl-lang/tap
brew install kcl
brew install go-task/tap/go-task gum
```

</details>

<details><summary>GENERATE ANSIBLE PIPELINERUNS</summary>

```bash
task --taskfile ../../taskfiles/tekton-runs.yaml create:ansible:pipelinerun


* inventory group name could be: all
* inventory host name could be: 10.100.136.136 or a fqdn
* storage class could be: openebs-hostpath
* storage class could be: tekton-ci


```

</details>
